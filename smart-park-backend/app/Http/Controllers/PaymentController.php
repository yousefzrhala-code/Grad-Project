<?php

namespace App\Http\Controllers;

use App\Models\Payment;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

class PaymentController extends Controller
{
    public const DEMO_CARD_NUMBER = '4242424242424242';
    public const DEMO_CARD_CVV = '123';
    public const DEMO_CARD_EXP = '12/30';

    public function pay(Request $request)
    {
        $validated = $request->validate([
            'reservation_id' => 'nullable|exists:reservations,id',
            'amount' => 'required|numeric|min:0',
            'payment_method' => 'required|in:card,cash',
            'card_number' => 'required_if:payment_method,card|string',
            'card_holder' => 'required_if:payment_method,card|string|max:255',
            'card_expiry' => 'required_if:payment_method,card|string|max:10',
            'card_cvv' => 'required_if:payment_method,card|string|max:6',
        ]);

        $user = $request->user();
        $method = $validated['payment_method'];

        if ($method === 'cash') {
            return $this->storeCashPayment($user->id, $validated);
        }

        return $this->storeCardPayment($user->id, $validated);
    }

    protected function storeCashPayment(int $userId, array $data)
    {
        $payment = Payment::create([
            'user_id' => $userId,
            'reservation_id' => $data['reservation_id'] ?? null,
            'amount' => $data['amount'],
            'currency' => 'JOD',
            'payment_method' => 'cash',
            'card_last4' => null,
            'card_holder' => null,
            'status' => 'pending_cash',
            'transaction_id' => 'CASH_' . strtoupper(Str::random(12)),
        ]);

        return response()->json([
            'message' => 'Cash payment reserved. Please pay on arrival.',
            'payment' => $payment,
        ], 201);
    }

    protected function storeCardPayment(int $userId, array $data)
    {
        $cleanNumber = preg_replace('/\s+/', '', $data['card_number']);
        $last4 = substr($cleanNumber, -4);

        $isDemo = $cleanNumber === self::DEMO_CARD_NUMBER
            && $data['card_cvv'] === self::DEMO_CARD_CVV
            && $data['card_expiry'] === self::DEMO_CARD_EXP;

        $status = $isDemo ? 'succeeded' : 'failed';

        $payment = Payment::create([
            'user_id' => $userId,
            'reservation_id' => $data['reservation_id'] ?? null,
            'amount' => $data['amount'],
            'currency' => 'JOD',
            'payment_method' => 'card',
            'card_last4' => $last4,
            'card_holder' => $data['card_holder'],
            'status' => $status,
            'transaction_id' => 'TXN_' . strtoupper(Str::random(12)),
        ]);

        if (!$isDemo) {
            return response()->json([
                'message' => 'Payment failed. Use the demo card to test.',
                'payment' => $payment,
                'demo_card' => self::demoCardInfo(),
            ], 402);
        }

        return response()->json([
            'message' => 'Payment successful',
            'payment' => $payment,
            'demo_card' => self::demoCardInfo(),
        ], 201);
    }

    public function myPayments(Request $request)
    {
        $user = $request->user();

        $payments = Payment::with('reservation.garage')
            ->where('user_id', $user->id)
            ->orderByDesc('created_at')
            ->get();

        return response()->json([
            'payments' => $payments,
            'demo_card' => self::demoCardInfo(),
        ]);
    }

    public function demoCard()
    {
        return response()->json(self::demoCardInfo());
    }

    public static function demoCardInfo(): array
    {
        return [
            'number' => self::DEMO_CARD_NUMBER,
            'cvv' => self::DEMO_CARD_CVV,
            'expiry' => self::DEMO_CARD_EXP,
            'holder' => 'SMART PARK',
            'brand' => 'VISA',
        ];
    }
}
