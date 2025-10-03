<!DOCTYPE html>
<html lang="tr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{{ $data['header']['title'] }}</title>
    <style>
        body {
            font-family: 'DejaVu Sans', Arial, sans-serif;
            margin: 0;
            padding: 20px;
            font-size: 12px;
            line-height: 1.4;
        }
        .header {
            text-align: center;
            margin-bottom: 30px;
            border-bottom: 2px solid #333;
            padding-bottom: 20px;
        }
        .header h1 {
            color: #333;
            margin: 0;
            font-size: 24px;
        }
        .header .info {
            margin-top: 10px;
            color: #666;
        }
        .summary {
            background-color: #f8f9fa;
            padding: 15px;
            border-radius: 5px;
            margin-bottom: 30px;
        }
        .summary h2 {
            margin: 0 0 15px 0;
            color: #333;
            font-size: 18px;
        }
        .summary-grid {
            display: table;
            width: 100%;
        }
        .summary-item {
            display: table-cell;
            text-align: center;
            padding: 10px;
            border-right: 1px solid #ddd;
        }
        .summary-item:last-child {
            border-right: none;
        }
        .summary-value {
            font-size: 20px;
            font-weight: bold;
            color: #007bff;
        }
        .summary-label {
            font-size: 11px;
            color: #666;
            margin-top: 5px;
        }
        .machines-section h2 {
            color: #333;
            margin-bottom: 20px;
            font-size: 18px;
        }
        .machine-card {
            border: 1px solid #ddd;
            border-radius: 5px;
            margin-bottom: 20px;
            page-break-inside: avoid;
        }
        .machine-header {
            background-color: #f1f3f4;
            padding: 15px;
            border-bottom: 1px solid #ddd;
        }
        .machine-title {
            font-size: 16px;
            font-weight: bold;
            color: #333;
            margin: 0;
        }
        .machine-code {
            color: #666;
            font-size: 11px;
            margin-top: 5px;
        }
        .machine-details {
            padding: 15px;
        }
        .detail-row {
            display: table;
            width: 100%;
            margin-bottom: 10px;
        }
        .detail-label {
            display: table-cell;
            width: 30%;
            font-weight: bold;
            color: #555;
        }
        .detail-value {
            display: table-cell;
            color: #333;
        }
        .status-badge {
            padding: 3px 8px;
            border-radius: 3px;
            font-size: 10px;
            font-weight: bold;
            color: white;
        }
        .status-active { background-color: #28a745; }
        .status-maintenance { background-color: #ffc107; }
        .status-inactive { background-color: #dc3545; }
        .progress-bar {
            width: 100%;
            height: 20px;
            background-color: #e9ecef;
            border-radius: 10px;
            overflow: hidden;
            margin-top: 5px;
        }
        .progress-fill {
            height: 100%;
            background-color: #007bff;
            transition: width 0.3s ease;
        }
        .footer {
            margin-top: 50px;
            text-align: center;
            font-size: 10px;
            color: #666;
            border-top: 1px solid #ddd;
            padding-top: 15px;
        }
        .page-break {
            page-break-before: always;
        }
    </style>
</head>
<body>
    <!-- Header -->
    <div class="header">
        <h1>{{ $data['header']['title'] }}</h1>
        <div class="info">
            <p><strong>Rapor Tarihi:</strong> {{ $data['header']['generated_at'] }}</p>
            <p><strong>Rapor Dönemi:</strong> {{ $data['header']['period'] }}</p>
            <p><strong>Toplam Makine Sayısı:</strong> {{ $data['header']['total_machines'] }}</p>
        </div>
    </div>

    <!-- Summary -->
    <div class="summary">
        <h2>Özet İstatistikler</h2>
        <div class="summary-grid">
            <div class="summary-item">
                <div class="summary-value">{{ $data['summary']['total_control_lists'] }}</div>
                <div class="summary-label">Toplam Kontrol Listesi</div>
            </div>
            <div class="summary-item">
                <div class="summary-value">{{ $data['summary']['completed_control_lists'] }}</div>
                <div class="summary-label">Tamamlanan</div>
            </div>
            <div class="summary-item">
                <div class="summary-value">{{ $data['summary']['pending_control_lists'] }}</div>
                <div class="summary-label">Bekleyen</div>
            </div>
            <div class="summary-item">
                <div class="summary-value">{{ $data['summary']['failed_control_lists'] }}</div>
                <div class="summary-label">Başarısız</div>
            </div>
            <div class="summary-item">
                <div class="summary-value">%{{ $data['summary']['average_completion_rate'] }}</div>
                <div class="summary-label">Ortalama Tamamlanma Oranı</div>
            </div>
        </div>
    </div>

    <!-- Machines Section -->
    <div class="machines-section">
        <h2>Makine Detayları</h2>

        @foreach($data['machines'] as $index => $machine)
            @if($index > 0 && $index % 3 == 0)
                <div class="page-break"></div>
            @endif

            <div class="machine-card">
                <div class="machine-header">
                    <div class="machine-title">{{ $machine['name'] }}</div>
                    <div class="machine-code">Kod: {{ $machine['code'] }} | Tip: {{ $machine['type'] }}</div>
                </div>
                <div class="machine-details">
                    <div class="detail-row">
                        <div class="detail-label">Lokasyon:</div>
                        <div class="detail-value">{{ $machine['location'] }}</div>
                    </div>
                    <div class="detail-row">
                        <div class="detail-label">Durum:</div>
                        <div class="detail-value">
                            <span class="status-badge status-{{ $machine['status'] }}">
                                {{ ucfirst($machine['status']) }}
                            </span>
                        </div>
                    </div>
                    <div class="detail-row">
                        <div class="detail-label">Son Bakım:</div>
                        <div class="detail-value">{{ $machine['last_maintenance'] ?? 'Belirtilmemiş' }}</div>
                    </div>
                    <div class="detail-row">
                        <div class="detail-label">Sonraki Bakım:</div>
                        <div class="detail-value">{{ $machine['next_maintenance'] ?? 'Belirtilmemiş' }}</div>
                    </div>

                    <hr style="margin: 15px 0; border: none; border-top: 1px solid #ddd;">

                    <div class="detail-row">
                        <div class="detail-label">Kontrol Listesi İstatistikleri:</div>
                        <div class="detail-value"></div>
                    </div>
                    <div class="detail-row">
                        <div class="detail-label">Toplam:</div>
                        <div class="detail-value">{{ $machine['control_lists']['total'] }}</div>
                    </div>
                    <div class="detail-row">
                        <div class="detail-label">Tamamlanan:</div>
                        <div class="detail-value">{{ $machine['control_lists']['completed'] }}</div>
                    </div>
                    <div class="detail-row">
                        <div class="detail-label">Bekleyen:</div>
                        <div class="detail-value">{{ $machine['control_lists']['pending'] }}</div>
                    </div>
                    <div class="detail-row">
                        <div class="detail-label">Başarısız:</div>
                        <div class="detail-value">{{ $machine['control_lists']['failed'] }}</div>
                    </div>
                    <div class="detail-row">
                        <div class="detail-label">Tamamlanma Oranı:</div>
                        <div class="detail-value">
                            %{{ $machine['control_lists']['completion_rate'] }}
                            <div class="progress-bar">
                                <div class="progress-fill" style="width: {{ $machine['control_lists']['completion_rate'] }}%"></div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        @endforeach
    </div>

    <!-- Footer -->
    <div class="footer">
        <p>Bu rapor SmartOP sistemi tarafından otomatik olarak oluşturulmuştur.</p>
        <p>Rapor oluşturulma tarihi: {{ $data['header']['generated_at'] }}</p>
    </div>
</body>
</html>