<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <style>
        body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
        .container { max-width: 600px; margin: 0 auto; padding: 20px; }
        .header { background: #28a745; color: white; padding: 20px; text-align: center; border-radius: 5px 5px 0 0; }
        .content { background: #f9f9f9; padding: 30px; border: 1px solid #ddd; }
        .info-box { background: white; padding: 15px; margin: 15px 0; border-left: 4px solid #28a745; }
        .footer { text-align: center; padding: 20px; color: #666; font-size: 12px; }
        h1 { margin: 0; font-size: 24px; }
        .label { font-weight: bold; color: #555; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>✓ Kontrol Listesi Onaylandı</h1>
        </div>
        <div class="content">
            <p>Merhaba {{ $operator->name }},</p>
            <p>{{ $machine->name }} makinesi için gönderdiğiniz kontrol listesi onaylandı.</p>
            
            <div class="info-box">
                <p><span class="label">Kontrol Listesi:</span> {{ $controlList->title }}</p>
                <p><span class="label">Makine:</span> {{ $machine->name }} ({{ $machine->code }})</p>
                <p><span class="label">Onaylayan:</span> {{ $approver->name }}</p>
                <p><span class="label">Onay Tarihi:</span> {{ $controlList->approved_at->format('d.m.Y H:i') }}</p>
                @if($controlList->notes)
                <p><span class="label">Not:</span> {{ $controlList->notes }}</p>
                @endif
            </div>
            
            <p>Çalışmanız için teşekkür ederiz!</p>
        </div>
        <div class="footer">
            <p>Bu e-posta SmartOp sistemi tarafından otomatik olarak gönderilmiştir.</p>
        </div>
    </div>
</body>
</html>
