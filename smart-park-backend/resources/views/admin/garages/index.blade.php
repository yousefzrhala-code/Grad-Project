@extends('admin.layout')


@section('content')
<div class="container py-4">
    <h2 class="mb-4">All Garages</h2>

    @if(session('success'))
    <div class="alert alert-success">{{ session('success') }}</div>
    @endif
    <a href="{{ route('admin.garages.create') }}" class="btn btn-primary mb-3">
        Add Garage
    </a>
    <div class="card shadow-sm">
        <div class="card-body table-responsive">
            <table class="table table-bordered align-middle">
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Garage Name</th>
                        <th>Owner</th>
                        <th>City</th>
                        <th>Price/Hour</th>
                        <th>Capacity</th>
                        <th>Status</th>
                        <th>Approval</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    @foreach($garages as $garage)
                    <tr>
                        <td>{{ $garage->id }}</td>
                        <td>{{ $garage->name }}</td>
                        <td>{{ $garage->owner->name ?? '-' }}</td>
                        <td>{{ $garage->city }}</td>
                        <td>{{ $garage->price_per_hour }}</td>
                        <td>{{ $garage->capacity }}</td>
                        <td>{{ $garage->is_active ? 'Active' : 'Inactive' }}</td>
                        <td>{{ $garage->approval_status }}</td>
                        <td>
                            <form action="{{ route('admin.garages.approve', $garage->id) }}" method="POST" class="d-inline">
                                @csrf
                                <button class="btn btn-success btn-sm">Approve</button>
                            </form>

                            <form action="{{ route('admin.garages.reject', $garage->id) }}" method="POST" class="d-inline">
                                @csrf
                                <button class="btn btn-warning btn-sm">Reject</button>
                            </form>

                            <form action="{{ route('admin.garages.delete', $garage->id) }}" method="POST" class="d-inline">
                                @csrf
                                @method('DELETE')
                                <button class="btn btn-danger btn-sm">Delete</button>
                            </form>
                        </td>
                    </tr>
                    @endforeach
                </tbody>
            </table>
        </div>
    </div>
</div>
@endsection