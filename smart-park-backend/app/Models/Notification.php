<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Notification extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'reservation_id',
        'title',
        'message',
        'is_read',
        'read_at',
    ];

    protected $casts = [
        'is_read' => 'boolean',
        'read_at' => 'datetime',
    ];

    public function user()
    {
        return $this->belongsTo(User::class, 'user_id');
    }

    public function reservation()
    {
        return $this->belongsTo(Reservation::class, 'reservation_id');
    }

    public static function send(int $userId, string $title, string $message, ?int $reservationId = null)
    {
        $record = self::create([
            'user_id' => $userId,
            'reservation_id' => $reservationId,
            'title' => $title,
            'message' => $message,
            'is_read' => false,
        ]);

        // Try to push to FCM if user has a token. Failures are silently swallowed
        // so they never break the surrounding business flow.
        try {
            $user = User::find($userId);
            if ($user && !empty($user->fcm_token)) {
                \App\Services\FcmService::send($user->fcm_token, $title, $message, [
                    'reservation_id' => (string) ($reservationId ?? ''),
                ]);
            }
        } catch (\Throwable $e) {
            // ignore
        }

        return $record;
    }
}
