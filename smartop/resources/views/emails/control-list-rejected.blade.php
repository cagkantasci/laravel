<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <style>
        body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
        .container { max-width: 600px; margin: 0 auto; padding: 20px; }
        .header { background: #dc3545; color: white; padding: 20px; text-align: center; border-radius: 5px 5px 0 0; }
        .content { background: #f9f9f9; padding: 30px; border: 1px solid #ddd; }
        .info-box { background: white; padding: 15px; margin: 15px 0; border-left: 4px solid #dc3545; }
        .reason-box { background: #fff3cd; padding: 15px; margin: 15px 0; border: 1px solid #ffc107; border-radius: 5px; }
        .footer { text-align: center; padding: 20px; color: #666; font-size: 12px; }
        h1 { margin: 0; font-size: 24px; }
        .label { font-weight: bold; color: #555; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>⚠ Kontrol Listesi Reddedildi</h1>
        </div>
        <div class="content">
            <p>Merhaba {{ $operator->name }},</p>
            <p>{{ $machine->name }} makinesi için gönderdiğiniz kontrol listesi reddedildi.</p>
            
            <div class="info-box">
                <p><span class="label">Kontrol Listesi:</span> {{ $controlList->title }}</p>
                <p><span class="label">Makine:</span> {{ $machine->name }} ({{ $machine->code }})</p>
                <p><span class="label">Reddeden:</span> {{ $approver->name }}</p>
                <p><span class="label">Red Tarihi:</span> {{ $controlList->approved_at->format('d.m.Y H:i') }}</p>
            </div>
            
            <div class="reason-box">
                <p><span class="label">Red Nedeni:</span></p>
                <p>{{ $rejectionReason }}</p>
            </div>
            
            <p>Lütfen gerekli düzeltmeleri yaparak kontrol listesini yeniden gönderin.</p>
        </div>
        <div class="footer">
            <p>Bu e-posta SmartOp sistemi tarafından otomatik olarak gönderilmiştir.</p>
        </div>
    </div>
</body>
</html>
