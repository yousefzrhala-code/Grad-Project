<?php

namespace App\Http\Controllers;

use App\Models\Garage;
use App\Models\Notification;
use App\Models\Payment;
use App\Models\Reservation;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Str;

class ReservationController extends Controller
{
    private const DEMO_CARD_NUMBER = '4242424242424242';
    private const DEMO_CARD_CVV    = '123';
    private const DEMO_CARD_EXP    = '12/30';
    public function store(Request $request)
    {
        $user = $request->user();

        if ($user->role !== 'car_owner') {
            return response()->json([
                'message' => 'Only car owners can make reservations.',
            ], 403);
        }

        $validated = $request->validate([
            'garage_id'        => 'required|exists:garages,id',
            'reservation_date' => 'required|date|after_or_equal:today',
            'start_time'       => 'required|date_format:H:i',
            'end_time'         => 'required|date_format:H:i|after:start_time',
            'number_of_spots'  => 'nullable|integer|min:1|max:20',
            // Payment
            'payment_method'   => 'required|in:card,cash',
            'card_number'      => 'required_if:payment_method,card|string',
            'card_holder'      => 'required_if:payment_method,card|string|max:255',
            'card_expiry'      => 'required_if:payment_method,card|string|max:10',
            'card_cvv'         => 'required_if:payment_method,card|string|max:6',
        ]);

        $garage = Garage::findOrFail($validated['garage_id']);

        // Garage must be approved and open for business
        if (!$garage->is_approved || !$garage->is_active) {
            return response()->json([
                'message' => 'This garage is not currently accepting reservations.',
            ], 422);
        }

        $numberOfSpots = $validated['number_of_spots'] ?? 1;
        $startHis      = $validated['start_time'] . ':00';
        $endHis        = $validated['end_time'] . ':00';

        // Availability check
        $reservedSpots = Reservation::reservedSpotsInTimeRange(
            $garage->id,
            $validated['reservation_date'],
            $startHis,
            $endHis
        );

        $availableSpots = $garage->capacity - $reservedSpots;

        if ($numberOfSpots > $availableSpots) {
            return response()->json([
                'message'         => 'Not enough spots available for the selected time slot.',
                'available_spots' => max(0, $availableSpots),
            ], 409);
        }

        $pricePerHour = (float) ($garage->price_per_hour ?? 0);
        $totalCost    = Reservation::calculateTotalCost($pricePerHour, $startHis, $endHis, $numberOfSpots);

        // Validate card BEFORE opening a transaction (no DB writes on card failure)
        if ($validated['payment_method'] === 'card' && !$this->isDemoCard($validated)) {
            return response()->json([
                'message'   => 'Payment failed. Your card was declined.',
                'demo_card' => $this->demoCardInfo(),
            ], 402);
        }

        // Atomic: reservation + payment created together or not at all
        $result = DB::transaction(function () use (
            $user,
            $garage,
            $validated,
            $numberOfSpots,
            $pricePerHour,
            $totalCost,
            $startHis,
            $endHis
        ) {
            $reservation = Reservation::create([
                'car_owner_id'     => $user->id,
                'garage_id'        => $garage->id,
                'reservation_date' => $validated['reservation_date'],
                'start_time'       => $startHis,
                'end_time'         => $endHis,
                'number_of_spots'  => $numberOfSpots,
                'status'           => 'pending',
                'price_per_hour'   => $pricePerHour,
                'total_cost'       => $totalCost,
            ]);

            $isCard   = $validated['payment_method'] === 'card';
            $cleanNum = $isCard ? preg_replace('/\s+/', '', $validated['card_number']) : null;

            $payment = Payment::create([
                'user_id'        => $user->id,
                'reservation_id' => $reservation->id,
                'amount'         => $totalCost,
                'currency'       => 'JOD',
                'payment_method' => $validated['payment_method'],
                'card_last4'     => $isCard ? substr($cleanNum, -4) : null,
                'card_holder'    => $isCard ? $validated['card_holder'] : null,
                'status'         => $isCard ? 'succeeded' : 'pending_cash',
                'transaction_id' => ($isCard ? 'TXN_' : 'CASH_') . strtoupper(Str::random(12)),
            ]);

            return compact('reservation', 'payment');
        });

        // Notify garage owner — failure must never affect the response
        try {
            if ($garage->owner_id) {
                Notification::send(
                    $garage->owner_id,
                    'New reservation request',
                    "{$user->name} requested a reservation at {$garage->name}.",
                    $result['reservation']->id
                );
            }
        } catch (\Throwable $e) {
            Log::warning('Booking notification failed: ' . $e->getMessage());
        }

        return response()->json([
            'message'     => 'Reservation created successfully.',
            'reservation' => $result['reservation']->load('garage', 'carOwner'),
            'payment'     => $result['payment'],
        ], 201);
    }

    public function myReservations(Request $request)
    {
        $reservations = Reservation::with('garage.owner:id,name,phone', 'payment')
            ->where('car_owner_id', $request->user()->id)
            ->orderByDesc('reservation_date')
            ->orderByDesc('start_time')
            ->get();

        return response()->json(['reservations' => $reservations]);
    }

    public function upcomingReservations(Request $request)
    {
        $today = now()->toDateString();
        $now   = now()->format('H:i:s');

        $reservations = Reservation::with('garage.owner:id,name,phone', 'payment')
            ->where('car_owner_id', $request->user()->id)
            ->whereIn('status', ['pending', 'accepted'])
            ->where(function ($q) use ($today, $now) {
                $q->where('reservation_date', '>', $today)
                    ->orWhere(function ($q2) use ($today, $now) {
                        $q2->where('reservation_date', $today)
                            ->where('end_time', '>=', $now);
                    });
            })
            ->orderBy('reservation_date')
            ->orderBy('start_time')
            ->get();

        return response()->json(['reservations' => $reservations]);
    }

    public function previousReservations(Request $request)
    {
        $today = now()->toDateString();
        $now   = now()->format('H:i:s');

        $reservations = Reservation::with('garage.owner:id,name,phone', 'payment')
            ->where('car_owner_id', $request->user()->id)
            ->where(function ($q) use ($today, $now) {
                $q->whereIn('status', ['cancelled', 'completed', 'rejected'])
                    ->orWhere(function ($q2) use ($today, $now) {
                        $q2->where('reservation_date', '<', $today)
                            ->orWhere(function ($q3) use ($today, $now) {
                                $q3->where('reservation_date', $today)
                                    ->where('end_time', '<', $now);
                            });
                    });
            })
            ->orderByDesc('reservation_date')
            ->orderByDesc('start_time')
            ->get();

        return response()->json(['reservations' => $reservations]);
    }

    public function cancel(Request $request, $id)
    {
        $user = $request->user();

        $request->validate([
            'cancel_reason' => 'nullable|string|max:1000',
        ]);

        $reservation = Reservation::with('garage')
            ->where('id', $id)
            ->where('car_owner_id', $user->id)
            ->first();

        if (!$reservation) {
            return response()->json(['message' => 'Reservation not found.'], 404);
        }

        if (in_array($reservation->status, ['cancelled', 'completed', 'rejected'])) {
            return response()->json(['message' => 'This reservation cannot be cancelled.'], 422);
        }

        if (!$reservation->canBeCancelled()) {
            return response()->json([
                'message' => 'Reservations can only be cancelled at least 2 hours before the start time.',
            ], 422);
        }

        $reservation->update([
            'status'        => 'cancelled',
            'cancelled_at'  => now(),
            'cancel_reason' => $request->cancel_reason,
            'cancelled_by'  => 'car_owner',
        ]);

        try {
            if ($reservation->garage && $reservation->garage->owner_id) {
                Notification::send(
                    $reservation->garage->owner_id,
                    'Reservation cancelled',
                    "{$user->name} cancelled their reservation at {$reservation->garage->name}.",
                    $reservation->id
                );
            }
        } catch (\Throwable $e) {
            Log::warning('Cancel notification failed: ' . $e->getMessage());
        }

        return response()->json([
            'message'     => 'Reservation cancelled successfully.',
            'reservation' => $reservation->load('garage', 'carOwner', 'payment'),
        ]);
    }

    public function garageOwnerReservations(Request $request)
    {
        $garage = $request->user()->garage;

        if (!$garage) {
            return response()->json(['message' => 'You do not have a garage.'], 404);
        }
        $status = $request->query('status');
        $query = Reservation::with('carOwner', 'payment')
            ->where('garage_id', $garage->id);
        if ($status) {
            $query->where('status', $status);
        } else {
            $query->whereIn('status', ['pending', 'accepted']);
        }
        $reservations = $query
            ->orderByDesc('reservation_date')
            ->orderByDesc('start_time')
            ->get();

        return response()->json(['reservations' => $reservations]);
    }

    public function respondToReservation(Request $request, $id)
    {
        $user = $request->user();

        if ($user->role !== 'garage_owner') {
            return response()->json(['message' => 'Unauthorized.'], 403);
        }

        $request->validate([
            'status'              => 'required|in:accepted,rejected',
            'owner_response_note' => 'nullable|string|max:1000',
        ]);

        $reservation = Reservation::with('garage')->find($id);

        if (!$reservation) {
            return response()->json(['message' => 'Reservation not found.'], 404);
        }

        if (!$reservation->garage || $reservation->garage->owner_id !== $user->id) {
            return response()->json(['message' => 'You cannot modify this reservation.'], 403);
        }

        if ($reservation->status !== 'pending') {
            return response()->json(['message' => 'Only pending reservations can be accepted or rejected.'], 422);
        }

        $reservation->update([
            'status'              => $request->status,
            'owner_response_note' => $request->owner_response_note,
        ]);

        try {
            Notification::send(
                $reservation->car_owner_id,
                $request->status === 'accepted' ? 'Reservation accepted' : 'Reservation rejected',
                $request->status === 'accepted'
                    ? "Your reservation at {$reservation->garage->name} has been accepted."
                    : "Your reservation at {$reservation->garage->name} has been rejected.",
                $reservation->id
            );
        } catch (\Throwable $e) {
            Log::warning('Respond notification failed: ' . $e->getMessage());
        }

        return response()->json([
            'message'     => $request->status === 'accepted'
                ? 'Reservation accepted successfully.'
                : 'Reservation rejected.',
            'reservation' => $reservation->load('garage', 'carOwner', 'payment'),
        ]);
    }

    public function cancelByOwner(Request $request, $id)
    {
        $user = $request->user();

        if ($user->role !== 'garage_owner') {
            return response()->json(['message' => 'Unauthorized.'], 403);
        }

        $request->validate([
            'cancel_reason' => 'nullable|string|max:1000',
        ]);

        $reservation = Reservation::with('garage', 'carOwner')->find($id);

        if (!$reservation) {
            return response()->json(['message' => 'Reservation not found.'], 404);
        }

        if (!$reservation->garage || $reservation->garage->owner_id !== $user->id) {
            return response()->json(['message' => 'You cannot modify this reservation.'], 403);
        }

        if (in_array($reservation->status, ['cancelled', 'completed', 'rejected'])) {
            return response()->json(['message' => 'This reservation cannot be cancelled.'], 422);
        }

        $reservation->update([
            'status'        => 'cancelled',
            'cancelled_at'  => now(),
            'cancel_reason' => $request->cancel_reason ?? 'Cancelled by garage owner.',
            'cancelled_by'  => 'garage_owner',
        ]);

        try {
            Notification::send(
                $reservation->car_owner_id,
                'Reservation cancelled by garage',
                "Your reservation at {$reservation->garage->name} was cancelled by the garage owner.",
                $reservation->id
            );
        } catch (\Throwable $e) {
            Log::warning('Owner cancel notification failed: ' . $e->getMessage());
        }

        return response()->json([
            'message'     => 'Reservation cancelled successfully.',
            'reservation' => $reservation->fresh()->load('garage', 'carOwner', 'payment'),
        ]);
    }

    public function checkIn(Request $request, $id)
    {
        $user        = $request->user();
        $reservation = Reservation::with('garage')->find($id);

        if (!$reservation) {
            return response()->json(['message' => 'Reservation not found.'], 404);
        }

        $isCarOwner   = $reservation->car_owner_id === $user->id;
        $isGarageOwner = $reservation->garage && $reservation->garage->owner_id === $user->id;

        if (!$isCarOwner && !$isGarageOwner) {
            return response()->json(['message' => 'Unauthorized.'], 403);
        }

        if ($reservation->status !== 'accepted') {
            return response()->json(['message' => 'Only accepted reservations can be checked in.'], 422);
        }

        if ($reservation->checked_in_at) {
            return response()->json([
                'message'     => 'Already checked in.',
                'reservation' => $reservation->load('garage', 'carOwner', 'payment'),
            ]);
        }

        $reservation->update([
            'checked_in_at' => now(),
            'checked_in_by' => $isGarageOwner ? 'garage_owner' : 'car_owner',
        ]);

        try {
            $otherUserId = $isGarageOwner
                ? $reservation->car_owner_id
                : $reservation->garage->owner_id;

            if ($otherUserId) {
                Notification::send(
                    $otherUserId,
                    'Checked in',
                    "Reservation at {$reservation->garage->name} has been checked in.",
                    $reservation->id
                );
            }
        } catch (\Throwable $e) {
            Log::warning('Check-in notification failed: ' . $e->getMessage());
        }

        return response()->json([
            'message'     => 'Checked in successfully.',
            'reservation' => $reservation->fresh()->load('garage', 'carOwner', 'payment'),
        ]);
    }

    public function checkOut(Request $request, $id)
    {
        $user        = $request->user();
        $reservation = Reservation::with('garage')->find($id);

        if (!$reservation) {
            return response()->json(['message' => 'Reservation not found.'], 404);
        }

        $isCarOwner   = $reservation->car_owner_id === $user->id;
        $isGarageOwner = $reservation->garage && $reservation->garage->owner_id === $user->id;

        if (!$isCarOwner && !$isGarageOwner) {
            return response()->json(['message' => 'Unauthorized.'], 403);
        }

        if ($reservation->status !== 'accepted') {
            return response()->json(['message' => 'Only accepted reservations can be checked out.'], 422);
        }

        if ($reservation->checked_out_at) {
            return response()->json([
                'message'     => 'Already checked out.',
                'reservation' => $reservation->load('garage', 'carOwner', 'payment'),
            ]);
        }

        $reservation->update([
            // Auto-fill check-in if the garage owner skipped that step
            // (e.g. tapped "Mark as Completed" directly).
            'checked_in_at'  => $reservation->checked_in_at ?? now(),
            'checked_in_by'  => $reservation->checked_in_by ?? ($isGarageOwner ? 'garage_owner' : 'car_owner'),
            'checked_out_at' => now(),
            'checked_out_by' => $isGarageOwner ? 'garage_owner' : 'car_owner',
            'status'         => 'completed',
        ]);

        try {
            $otherUserId = $isGarageOwner
                ? $reservation->car_owner_id
                : $reservation->garage->owner_id;

            if ($otherUserId) {
                Notification::send(
                    $otherUserId,
                    'Reservation completed',
                    "Reservation at {$reservation->garage->name} has been completed. "
                        . ($isGarageOwner ? '' : 'You can now rate your experience.'),
                    $reservation->id
                );
            }
        } catch (\Throwable $e) {
            Log::warning('Check-out notification failed: ' . $e->getMessage());
        }

        return response()->json([
            'message'     => 'Checked out successfully. Reservation is now completed.',
            'reservation' => $reservation->fresh()->load('garage', 'carOwner', 'payment'),
        ]);
    }

    public function statistics(Request $request)
    {
        $user = $request->user();

        if ($user->role !== 'garage_owner') {
            return response()->json(['message' => 'Unauthorized.'], 403);
        }

        $garage = $user->garage;

        if (!$garage) {
            return response()->json(['message' => 'You do not have a garage.'], 404);
        }

        $q = Reservation::where('garage_id', $garage->id);

        $total     = (clone $q)->count();
        $pending   = (clone $q)->where('status', 'pending')->count();
        $accepted  = (clone $q)->where('status', 'accepted')->count();
        $rejected  = (clone $q)->where('status', 'rejected')->count();
        $cancelled = (clone $q)->where('status', 'cancelled')->count();
        $completed = (clone $q)->where('status', 'completed')->count();

        // Revenue = sum of total_cost for completed reservations only
        $revenue = (clone $q)
            ->where('status', 'completed')
            ->sum('total_cost');

        return response()->json([
            'total_reservations'     => $total,
            'pending_reservations'   => $pending,
            'accepted_reservations'  => $accepted,
            'rejected_reservations'  => $rejected,
            'cancelled_reservations' => $cancelled,
            'completed_reservations' => $completed,
            'total_revenue'          => (float) $revenue,
            'currency'               => 'JOD',
        ]);
    }

    private function isDemoCard(array $data): bool
    {
        $clean = preg_replace('/\s+/', '', $data['card_number'] ?? '');

        return $clean                    === self::DEMO_CARD_NUMBER
            && ($data['card_cvv']    ?? '') === self::DEMO_CARD_CVV
            && ($data['card_expiry'] ?? '') === self::DEMO_CARD_EXP;
    }

    private function demoCardInfo(): array
    {
        return [
            'number' => self::DEMO_CARD_NUMBER,
            'cvv'    => self::DEMO_CARD_CVV,
            'expiry' => self::DEMO_CARD_EXP,
            'holder' => 'SMART PARK',
            'brand'  => 'VISA',
        ];
    }
}
