<?php

namespace App\Mail;

use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Mail\Mailable;
use Illuminate\Mail\Mailables\Content;
use Illuminate\Mail\Mailables\Envelope;
use Illuminate\Queue\SerializesModels;

class MachineStatusNotification extends Mailable implements ShouldQueue
{
    use Queueable, SerializesModels;

    public array $data;

    public function __construct(array $data)
    {
        $this->data = $data;
    }

    public function envelope(): Envelope
    {
        $machine = $this->data['machine'];
        $newStatus = $this->data['new_status'];

        $subject = "Machine Status Alert: {$machine->name} - {$newStatus}";

        return new Envelope(
            subject: $subject,
            from: config('mail.from.address', 'noreply@smartop.com'),
            replyTo: config('mail.support.address', 'support@smartop.com')
        );
    }

    public function content(): Content
    {
        return new Content(
            view: 'emails.machine-status-notification',
            with: $this->data
        );
    }

    public function attachments(): array
    {
        return [];
    }
}