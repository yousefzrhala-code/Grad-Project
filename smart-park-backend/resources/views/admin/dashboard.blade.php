@extends('admin.layout')
@section('content')
<div class="container py-4">
    <h2 class="mb-4">Admin Dashboard</h2>

    <div class="row g-4">
        <div class="col-md-3">
            <div class="card shadow-sm border-0">
                <div class="card-body">
                    <h6>Total Users</h6>
                    <h3>{{ $stats['total_users'] }}</h3>
                </div>
            </div>
        </div>

        <div class="col-md-3">
            <div class="card shadow-sm border-0">
                <div class="card-body">
                    <h6>Car Owners</h6>
                    <h3>{{ $stats['car_owners'] }}</h3>
                </div>
            </div>
        </div>

        <div class="col-md-3">
            <div class="card shadow-sm border-0">
                <div class="card-body">
                    <h6>Garage Owners</h6>
                    <h3>{{ $stats['garage_owners'] }}</h3>
                </div>
            </div>
        </div>

        <div class="col-md-3">
            <div class="card shadow-sm border-0">
                <div class="card-body">
                    <h6>Total Garages</h6>
                    <h3>{{ $stats['total_garages'] }}</h3>
                </div>
            </div>
        </div>

        <div class="col-md-3">
            <div class="card shadow-sm border-0">
                <div class="card-body">
                    <h6>Pending Garages</h6>
                    <h3>{{ $stats['pending_garages'] }}</h3>
                </div>
            </div>
        </div>

        <div class="col-md-3">
            <div class="card shadow-sm border-0">
                <div class="card-body">
                    <h6>Approved Garages</h6>
                    <h3>{{ $stats['approved_garages'] }}</h3>
                </div>
            </div>
        </div>

        <div class="col-md-3">
            <div class="card shadow-sm border-0">
                <div class="card-body">
                    <h6>Rejected Garages</h6>
                    <h3>{{ $stats['rejected_garages'] }}</h3>
                </div>
            </div>
        </div>

        <div class="col-md-3">
            <div class="card shadow-sm border-0">
                <div class="card-body">
                    <h6>Total Reservations</h6>
                    <h3>{{ $stats['total_reservations'] }}</h3>
                </div>
            </div>
        </div>

        <div class="col-md-3">
            <div class="card shadow-sm border-0">
                <div class="card-body">
                    <h6>Contact Messages</h6>
                    <h3>{{ $stats['contact_messages'] }}</h3>
                </div>
            </div>
        </div>

        <div class="col-md-3">
            <div class="card shadow-sm border-0">
                <div class="card-body">
                    <h6>New Messages</h6>
                    <h3>{{ $stats['new_messages'] }}</h3>
                </div>
            </div>
        </div>
    </div>
</div>
@endsection