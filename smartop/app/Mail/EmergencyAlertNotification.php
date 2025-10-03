<?php

namespace App\Mail;

use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Mail\Mailable;
use Illuminate\Mail\Mailables\Content;
use Illuminate\Mail\Mailables\Envelope;
use Illuminate\Queue\SerializesModels;

class EmergencyAlertNotification extends Mailable implements ShouldQueue
{
    use Queueable, SerializesModels;

    public array $data;

    public function __construct(array $data)
    {
        $this->data = $data;
    }

    public function envelope(): Envelope
    {
        $alertType = strtoupper($this->data['alert_type']);

        return new Envelope(
            subject: "🚨 EMERGENCY ALERT: {$alertType}",
            from: config('mail.from.address', 'noreply@smartop.com')
        );
    }

    public function content(): Content
    {
        return new Content(
            view: 'emails.emergency-alert',
            with: $this->data
        );
    }

    public function attachments(): array
    {
        return [];
    }
}