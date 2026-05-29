@extends('admin.layout')

@section('content')

<h2>Car Owners</h2>

<table class="table table-bordered">

<thead>

<tr>
<th>ID</th>
<th>Name</th>
<th>Email</th>
<th>Car Type</th>
<th>Delete</th>
</tr>

</thead>

<tbody>

@foreach($users as $user)

<tr>

<td>{{ $user->id }}</td>

<td>{{ $user->name }}</td>

<td>{{ $user->email }}</td>

<td>{{ $user->car_type }}</td>

<td>

<form action="/admin/users/{{ $user->id }}" method="POST">

@csrf
@method('DELETE')

<button class="btn btn-danger btn-sm">
Delete
</button>

</form>

</td>

</tr>

@endforeach

</tbody>

</table>

@endsection