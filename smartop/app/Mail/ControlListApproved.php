<?php

namespace App\Mail;

use App\Models\ControlList;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Mail\Mailable;
use Illuminate\Mail\Mailables\Content;
use Illuminate\Mail\Mailables\Envelope;
use Illuminate\Queue\SerializesModels;

class ControlListApproved extends Mailable implements ShouldQueue
{
    use Queueable, SerializesModels;

    public $controlList;

    /**
     * Create a new message instance.
     */
    public function __construct(ControlList $controlList)
    {
        $this->controlList = $controlList;
    }

    /**
     * Get the message envelope.
     */
    public function envelope(): Envelope
    {
        return new Envelope(
            subject: 'Kontrol Listesi Onaylandı - ' . $this->controlList->title,
        );
    }

    /**
     * Get the message content definition.
     */
    public function content(): Content
    {
        return new Content(
            view: 'emails.control-list-approved',
            with: [
                'controlList' => $this->controlList,
                'machine' => $this->controlList->machine,
                'operator' => $this->controlList->user,
                'approver' => $this->controlList->approver,
            ]
        );
    }

    /**
     * Get the attachments for the message.
     *
     * @return array<int, \Illuminate\Mail\Mailables\Attachment>
     */
    public function attachments(): array
    {
        return [];
    }
}
