<?php

namespace App\Console\Commands;

use App\Models\Notification;
use App\Models\Reservation;
use Carbon\Carbon;
use Illuminate\Console\Command;


class AutoCancelLateReservations extends Command
{
    protected $signature = 'reservations:auto-cancel';
    protected $description = 'Auto-cancel accepted reservations not checked-in within the grace period and complete finished reservations.';

    public function handle(): int
    {
        $now = Carbon::now();
        $grace = Reservation::CHECKIN_GRACE_MINUTES;

        $cancelled = 0;
        $completed = 0;
        Reservation::with('garage')
            ->where('status', 'accepted')
            ->whereNull('checked_in_at')
            ->get()
            ->each(function (Reservation $reservation) use ($now, $grace, &$cancelled) {
                $deadline = $reservation->startDateTime()->addMinutes($grace);

                if ($now->greaterThan($deadline)) {
                    $reservation->update([
                        'status' => 'cancelled',
                        'cancelled_at' => $now,
                        'cancel_reason' => 'Auto-cancelled: not checked in within grace period',
                    ]);

                    if ($reservation->garage) {
                        $reservation->garage->increment('available_spots', $reservation->number_of_spots);
                    }

                    Notification::send(
                        $reservation->car_owner_id,
                        'Reservation auto-cancelled',
                        'Your reservation was auto-cancelled because you did not check in within ' . $grace . ' minutes.',
                        $reservation->id
                    );

                    $cancelled++;
                }
            });

        Reservation::where('status', 'accepted')
            ->whereNotNull('checked_in_at')
            ->get()
            ->each(function (Reservation $reservation) use ($now, &$completed) {
                if ($now->greaterThan($reservation->endDateTime())) {
                    $reservation->update(['status' => 'completed']);
                    $completed++;
                }
            });

        $this->info("Auto-cancelled: $cancelled  |  Auto-completed: $completed");

        return self::SUCCESS;
    }
}
