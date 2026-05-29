@extends('admin.layout')

@section('content')

<h2>Add Garage</h2>

<form method="POST" action="{{ route('admin.garages.store') }}">
    @csrf

    <input type="text" name="name" placeholder="Garage Name" class="form-control mb-2" required>

    <select name="city" class="form-control mb-2" required>
        <option value="">Select City</option>

        <!-- Amman -->
        <option value="Amman">Amman</option>
        <option value="Sahab">Sahab</option>
        <option value="Marka">Marka</option>
        <option value="Abu Alanda">Abu Alanda</option>

        <!-- Zarqa -->
        <option value="Zarqa">Zarqa</option>
        <option value="Russeifa">Russeifa</option>
        <option value="Hashemite University Area">Hashemite University Area</option>

        <!-- Irbid -->
        <option value="Irbid">Irbid</option>
        <option value="Ramtha">Ramtha</option>
        <option value="Bani Kinanah">Bani Kinanah</option>

        <!-- Balqa -->
        <option value="Salt">Salt</option>
        <option value="Fuheis">Fuheis</option>

        <!-- Madaba -->
        <option value="Madaba">Madaba</option>

        <!-- Karak -->
        <option value="Karak">Karak</option>

        <!-- Tafileh -->
        <option value="Tafileh">Tafileh</option>

        <!-- Ma'an -->
        <option value="Ma'an">Ma'an</option>
        <option value="Petra">Petra</option>

        <!-- Aqaba -->
        <option value="Aqaba">Aqaba</option>

        <!-- Mafraq -->
        <option value="Mafraq">Mafraq</option>

        <!-- Jerash -->
        <option value="Jerash">Jerash</option>

        <!-- Ajloun -->
        <option value="Ajloun">Ajloun</option>

    </select>
    <input type="address" name="address" placeholder="Address" class="form-control mb-2" required>
    <input type="number" name="price_per_hour" placeholder="Price Per Hour" class="form-control mb-2" required>

    <input type="number" name="capacity" placeholder="Capacity" class="form-control mb-2" required>

    <select name="owner_id" class="form-control mb-2" required>
        <option value="">Select Garage Owner</option>
        @foreach($owners as $owner)
        <option value="{{ $owner->id }}">
            {{ $owner->name }} ({{ $owner->email }})
        </option>
        @endforeach
    </select>

    <button class="btn btn-success">Create Garage</button>

</form>

@endsection