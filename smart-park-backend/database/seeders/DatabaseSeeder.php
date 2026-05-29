<?php

namespace Database\Seeders;

use App\Models\Garage;
use App\Models\User;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class DatabaseSeeder extends Seeder
{
    use WithoutModelEvents;

    public function run(): void
    {
        $this->call(AdminUserSeeder::class);

        $garageOwner = User::create([
            'name'            => 'Garage Owner',
            'email'           => 'owner@smartpark.com',
            'password'        => Hash::make('password123'),
            'role'            => 'garage_owner',
            'phone'           => '0501234567',
            'approval_status' => 'approved',
            'is_active'       => true,
        ]);
        Garage::create([
            'owner_id'        => $garageOwner->id,
            'name'            => 'Smart Park Garage',
            'city'            => 'Riyadh',
            'address'         => 'King Fahd Road, Riyadh',
            'price_per_hour'  => 10.00,
            'capacity'        => 20,
            'available_spots' => 20,
            'open_time'       => '06:00:00',
            'close_time'      => '23:00:00',
            'description'     => 'Main test garage for development.',
            'is_active'       => true,
            'is_approved'     => true,
            'approval_status' => 'approved',
        ]);
        User::create([
            'name'            => 'Car Owner',
            'email'           => 'passenger@smartpark.com',
            'password'        => Hash::make('password123'),
            'role'            => 'car_owner',
            'car_type'        => 'Toyota Camry',
            'phone'           => '0509876543',
            'approval_status' => 'approved',
            'is_active'       => true,
        ]);
    }
}
