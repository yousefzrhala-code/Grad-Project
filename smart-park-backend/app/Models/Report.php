<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Report extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'garage_id',
        'subject',
        'message',
        'status',
    ];

    public function user()
    {
        return $this->belongsTo(User::class, 'user_id');
    }

    public function garage()
    {
        return $this->belongsTo(Garage::class, 'garage_id');
    }

    public static function createReport(array $data, int $userId)
    {
        return self::create([
            'user_id' => $userId,
            'garage_id' => $data['garage_id'],
            'subject' => $data['subject'],
            'message' => $data['message'],
            'status' => 'pending',
        ]);
    }
}
