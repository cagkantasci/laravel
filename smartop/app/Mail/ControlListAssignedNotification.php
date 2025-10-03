<?php

namespace App\Mail;

use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Mail\Mailable;
use Illuminate\Mail\Mailables\Content;
use Illuminate\Mail\Mailables\Envelope;
use Illuminate\Queue\SerializesModels;

class ControlListAssignedNotification extends Mailable implements ShouldQueue
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
        $priority = $this->data['priority'];

        $subject = "New Control List Assignment";
        if ($priority === 'high') {
            $subject = "🔴 URGENT: " . $subject;
        }
        $subject .= " - {$machine->name}";

        return new Envelope(
            subject: $subject,
            from: config('mail.from.address', 'noreply@smartop.com')
        );
    }

    public function content(): Content
    {
        return new Content(
            view: 'emails.control-list-assigned',
            with: $this->data
        );
    }

    public function attachments(): array
    {
        return [];
    }
}