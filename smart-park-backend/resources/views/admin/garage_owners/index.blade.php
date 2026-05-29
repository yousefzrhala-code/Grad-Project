@extends('admin.layout')

@section('content')

<h2>Garage Owners</h2>

<table class="table table-bordered">
    <a href="{{ route('admin.garageOwners.create') }}" class="btn btn-primary mb-3">
        Add Garage Owner
    </a>
    <thead>

        <tr>
            <th>ID</th>
            <th>Name</th>
            <th>Email</th>
            <th>Status</th>
            <th>Approve</th>
            <th>Reject</th>
            <th>Delete</th>
        </tr>

    </thead>

    <tbody>

        @foreach($users as $user)

        <tr>

            <td>{{ $user->id }}</td>

            <td>{{ $user->name }}</td>

            <td>{{ $user->email }}</td>

            <td>{{ $user->approval_status }}</td>

            <td>

                <form action="/admin/garage-owners/{{ $user->id }}/approve" method="POST">

                    @csrf

                    <button class="btn btn-success btn-sm">
                        Approve
                    </button>

                </form>

            </td>

            <td>

                <form action="/admin/garage-owners/{{ $user->id }}/reject" method="POST">

                    @csrf

                    <button class="btn btn-warning btn-sm">
                        Reject
                    </button>

                </form>

            </td>

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