@extends('admin.layout')

@section('content')
<div class="container py-4">
    <h2 class="mb-4">Garage Reports</h2>

    @if(session('success'))
    <div class="alert alert-success">{{ session('success') }}</div>
    @endif

    <div class="card shadow-sm">
        <div class="card-body table-responsive">
            <table class="table table-bordered align-middle">
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Reporter</th>
                        <th>Garage</th>
                        <th>Subject</th>
                        <th>Message</th>
                        <th>Status</th>
                        <th>Date</th>
                        <th style="min-width:240px">Actions</th>
                    </tr>
                </thead>
                <tbody>
                    @forelse($reports as $report)
                    <tr>
                        <td>{{ $report->id }}</td>
                        <td>
                            <strong>{{ $report->user->name ?? '-' }}</strong><br>
                            <small class="text-muted">{{ $report->user->email ?? '' }}</small>
                        </td>
                        <td>
                            <strong>{{ $report->garage->name ?? '-' }}</strong><br>
                            <small class="text-muted">{{ $report->garage->city ?? '' }}</small>
                        </td>
                        <td>{{ $report->subject }}</td>
                        <td style="max-width:340px">{{ $report->message }}</td>
                        <td>
                            @php
                                $color = $report->status === 'pending' ? 'warning'
                                    : ($report->status === 'reviewed' ? 'info' : 'success');
                            @endphp
                            <span class="badge bg-{{ $color }}">{{ ucfirst($report->status) }}</span>
                        </td>
                        <td>{{ $report->created_at->diffForHumans() }}</td>
                        <td>
                            @if($report->status === 'pending')
                            <form action="{{ route('admin.reports.reviewed', $report->id) }}" method="POST" class="d-inline">
                                @csrf
                                <button class="btn btn-info btn-sm">Mark Reviewed</button>
                            </form>
                            @endif
                            @if($report->status !== 'resolved')
                            <form action="{{ route('admin.reports.resolved', $report->id) }}" method="POST" class="d-inline">
                                @csrf
                                <button class="btn btn-success btn-sm">Resolve</button>
                            </form>
                            @endif
                            <form action="{{ route('admin.reports.delete', $report->id) }}" method="POST" class="d-inline">
                                @csrf
                                @method('DELETE')
                                <button class="btn btn-danger btn-sm">Delete</button>
                            </form>
                        </td>
                    </tr>
                    @empty
                    <tr>
                        <td colspan="8" class="text-center text-muted py-4">No garage reports yet.</td>
                    </tr>
                    @endforelse
                </tbody>
            </table>
        </div>
    </div>
</div>
@endsection
