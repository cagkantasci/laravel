@extends('emails.layout')

@section('title', 'Machine Status Alert - SmartOP')

@section('header', 'Machine Status Alert')

@section('content')
    @php
        $machine = $data['machine'];
        $oldStatus = $data['old_status'];
        $newStatus = $data['new_status'];
        $timestamp = $data['timestamp'];

        $alertClass = match($newStatus) {
            'failed', 'error' => 'alert-emergency',
            'maintenance' => 'alert-warning',
            'active' => 'alert-success',
            default => 'alert-info'
        };
    @endphp

    <div class="alert {{ $alertClass }}">
        <strong>Machine Status Changed!</strong><br>
        Machine <strong>{{ $machine->name }}</strong> status has changed from
        <span class="status-badge status-{{ $oldStatus }}">{{ ucfirst($oldStatus) }}</span> to
        <span class="status-badge status-{{ $newStatus }}">{{ ucfirst($newStatus) }}</span>
    </div>

    <h3>Machine Details</h3>
    <table class="details-table">
        <tr>
            <th>Machine Name</th>
            <td>{{ $machine->name }}</td>
        </tr>
        <tr>
            <th>Machine Code</th>
            <td>{{ $machine->machine_code }}</td>
        </tr>
        <tr>
            <th>Type</th>
            <td>{{ $machine->machine_type }}</td>
        </tr>
        <tr>
            <th>Location</th>
            <td>{{ $machine->location }}</td>
        </tr>
        <tr>
            <th>Previous Status</th>
            <td><span class="status-badge status-{{ $oldStatus }}">{{ ucfirst($oldStatus) }}</span></td>
        </tr>
        <tr>
            <th>Current Status</th>
            <td><span class="status-badge status-{{ $newStatus }}">{{ ucfirst($newStatus) }}</span></td>
        </tr>
        <tr>
            <th>Status Changed At</th>
            <td>{{ $timestamp->format('d/m/Y H:i') }}</td>
        </tr>
    </table>

    @if($newStatus === 'failed' || $newStatus === 'error')
        <div class="alert alert-emergency">
            <strong>Action Required!</strong><br>
            This machine requires immediate attention. Please check the machine status and take necessary action.
        </div>
        <a href="{{ config('app.frontend_url') }}/machines/{{ $machine->id }}" class="btn btn-emergency">
            View Machine Details
        </a>
    @elseif($newStatus === 'maintenance')
        <div class="alert alert-warning">
            <strong>Maintenance Mode</strong><br>
            This machine is currently under maintenance. Operations will resume once maintenance is completed.
        </div>
        <a href="{{ config('app.frontend_url') }}/machines/{{ $machine->id }}" class="btn">
            View Maintenance Details
        </a>
    @else
        <a href="{{ config('app.frontend_url') }}/machines/{{ $machine->id }}" class="btn">
            View Machine Details
        </a>
    @endif

    <p style="margin-top: 30px; color: #666; font-size: 14px;">
        You are receiving this notification because you are subscribed to machine status alerts for your company.
        To manage your notification preferences, please visit your account settings.
    </p>
@endsection