<?php

namespace App\Models;

use Carbon\Carbon;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class Reservation extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'car_owner_id',
        'garage_id',
        'reservation_date',
        'start_time',
        'end_time',
        'number_of_spots',
        'status',
        'price_per_hour',
        'total_cost',
        'cancelled_at',
        'cancel_reason',
        'owner_response_note',
        'checked_in_at',
        'checked_out_at',
        'checked_in_by',
        'checked_out_by',
        'cancelled_by',
    ];

    protected $casts = [
        'reservation_date' => 'date',
        'cancelled_at'     => 'datetime',
        'checked_in_at'    => 'datetime',
        'checked_out_at'   => 'datetime',
    ];

    // ── Relationships ─────────────────────────────────────────────────────────

    public function carOwner()
    {
        return $this->belongsTo(User::class, 'car_owner_id');
    }

    public function garage()
    {
        return $this->belongsTo(Garage::class);
    }

    /** All payments linked to this reservation (normally just one). */
    public function payments()
    {
        return $this->hasMany(Payment::class, 'reservation_id');
    }

    /** The single most-recent payment — use load('payment') for eager loading. */
    public function payment()
    {
        return $this->hasOne(Payment::class, 'reservation_id')->latestOfMany();
    }

    public function ratings()
    {
        return $this->hasMany(Rating::class, 'reservation_id');
    }

    // ── Constants ─────────────────────────────────────────────────────────────

    /** Minutes after start_time before a non-checked-in reservation is auto-cancelled. */
    public const CHECKIN_GRACE_MINUTES = 30;

    // ── Business logic ────────────────────────────────────────────────────────

    /**
     * Car owner may cancel only if the reservation start is more than 2 hours away
     * and it hasn't already been terminated.
     */
    public function canBeCancelled(): bool
    {
        if (in_array($this->status, ['cancelled', 'completed', 'rejected'])) {
            return false;
        }

        return $this->startDateTime()->greaterThan(Carbon::now()->addHours(2));
    }

    public function startDateTime(): Carbon
    {
        return Carbon::parse(
            Carbon::parse($this->reservation_date)->format('Y-m-d') . ' ' . $this->start_time
        );
    }

    public function endDateTime(): Carbon
    {
        return Carbon::parse(
            Carbon::parse($this->reservation_date)->format('Y-m-d') . ' ' . $this->end_time
        );
    }

    // ── Static helpers ────────────────────────────────────────────────────────

    /**
     * Sum of spots already booked in a garage for a given date/time window.
     * Used to check availability before creating a new reservation.
     */
    public static function reservedSpotsInTimeRange(
        int    $garageId,
        string $reservationDate,
        string $startTime,
        string $endTime
    ): int {
        return (int) self::where('garage_id', $garageId)
            ->where('reservation_date', $reservationDate)
            ->whereIn('status', ['pending', 'accepted'])
            ->where(function ($q) use ($startTime, $endTime) {
                $q->where('start_time', '<', $endTime)
                  ->where('end_time', '>', $startTime);
            })
            ->sum('number_of_spots');
    }

    /**
     * Calculate the total cost for a reservation.
     * Both $startTime and $endTime must be in H:i:s format.
     */
    public static function calculateTotalCost(
        float  $pricePerHour,
        string $startTime,
        string $endTime,
        int    $numberOfSpots = 1
    ): float {
        $start = Carbon::createFromFormat('H:i:s', $startTime);
        $end   = Carbon::createFromFormat('H:i:s', $endTime);
        $hours = $start->diffInMinutes($end) / 60;

        return round($hours * $pricePerHour * $numberOfSpots, 2);
    }
}
