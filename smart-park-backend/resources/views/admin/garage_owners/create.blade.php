@extends('admin.layout')

@section('content')
<h2>Add Garage Owner</h2>

<form method="POST" action="{{ route('admin.garageOwners.store') }}">
    @csrf

    <input type="text" name="name" placeholder="Name" class="form-control mb-2" required>
    <input type="email" name="email" placeholder="Email" class="form-control mb-2" required>
    <input type="mobile" name="mobile" placeholder="mobile" class="form-control mb-2" required>
    <input type="password" name="password" placeholder="Password" class="form-control mb-2" required>

    <button class="btn btn-success">Create</button>
</form>
@endsection