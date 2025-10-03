<!DOCTYPE html>
<html lang="tr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>@yield('title', 'SmartOP Notification')</title>
    <style>
        body {
            font-family: 'Arial', 'Helvetica', sans-serif;
            line-height: 1.6;
            margin: 0;
            padding: 0;
            background-color: #f4f4f4;
        }
        .container {
            max-width: 600px;
            margin: 0 auto;
            background-color: #ffffff;
            box-shadow: 0 0 10px rgba(0,0,0,0.1);
        }
        .header {
            background-color: #2c3e50;
            color: #ffffff;
            padding: 20px;
            text-align: center;
        }
        .header h1 {
            margin: 0;
            font-size: 24px;
        }
        .header .logo {
            font-size: 28px;
            font-weight: bold;
            margin-bottom: 5px;
        }
        .content {
            padding: 30px 20px;
        }
        .alert {
            padding: 15px;
            margin-bottom: 20px;
            border-radius: 4px;
        }
        .alert-emergency {
            background-color: #f8d7da;
            border: 1px solid #f5c6cb;
            color: #721c24;
        }
        .alert-warning {
            background-color: #fff3cd;
            border: 1px solid #ffeaa7;
            color: #856404;
        }
        .alert-info {
            background-color: #d1ecf1;
            border: 1px solid #bee5eb;
            color: #0c5460;
        }
        .alert-success {
            background-color: #d4edda;
            border: 1px solid #c3e6cb;
            color: #155724;
        }
        .details-table {
            width: 100%;
            border-collapse: collapse;
            margin: 20px 0;
        }
        .details-table th,
        .details-table td {
            text-align: left;
            padding: 12px;
            border-bottom: 1px solid #ddd;
        }
        .details-table th {
            background-color: #f8f9fa;
            font-weight: bold;
        }
        .btn {
            display: inline-block;
            padding: 12px 24px;
            background-color: #007bff;
            color: #ffffff;
            text-decoration: none;
            border-radius: 4px;
            margin: 10px 0;
            font-weight: bold;
        }
        .btn:hover {
            background-color: #0056b3;
        }
        .btn-emergency {
            background-color: #dc3545;
        }
        .btn-emergency:hover {
            background-color: #c82333;
        }
        .footer {
            background-color: #34495e;
            color: #ffffff;
            padding: 20px;
            text-align: center;
            font-size: 14px;
        }
        .footer a {
            color: #3498db;
            text-decoration: none;
        }
        .status-badge {
            padding: 5px 10px;
            border-radius: 3px;
            font-size: 12px;
            font-weight: bold;
            text-transform: uppercase;
        }
        .status-active {
            background-color: #d4edda;
            color: #155724;
        }
        .status-inactive {
            background-color: #f8d7da;
            color: #721c24;
        }
        .status-maintenance {
            background-color: #fff3cd;
            color: #856404;
        }
        .status-completed {
            background-color: #d4edda;
            color: #155724;
        }
        .status-pending {
            background-color: #fff3cd;
            color: #856404;
        }
        .status-failed {
            background-color: #f8d7da;
            color: #721c24;
        }
        .priority-high {
            color: #dc3545;
            font-weight: bold;
        }
        .priority-medium {
            color: #fd7e14;
            font-weight: bold;
        }
        .priority-low {
            color: #28a745;
        }
        @media only screen and (max-width: 600px) {
            .container {
                width: 100% !important;
                margin: 0 !important;
            }
            .content {
                padding: 20px 15px !important;
            }
            .details-table th,
            .details-table td {
                padding: 8px !important;
                font-size: 14px !important;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <div class="logo">SmartOP</div>
            <h1>@yield('header', 'System Notification')</h1>
        </div>

        <div class="content">
            @yield('content')
        </div>

        <div class="footer">
            <p>Bu email SmartOP sistemi tarafından otomatik olarak gönderilmiştir.</p>
            <p>
                <a href="{{ config('app.frontend_url') }}">SmartOP Dashboard</a> |
                <a href="mailto:{{ config('mail.support.address', 'support@smartop.com') }}">Destek</a>
            </p>
            <p style="font-size: 12px; color: #95a5a6;">
                © {{ date('Y') }} SmartOP. Tüm hakları saklıdır.
            </p>
        </div>
    </div>
</body>
</html>