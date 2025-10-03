<?php

namespace App\Exports;

use Maatwebsite\Excel\Concerns\FromArray;
use Maatwebsite\Excel\Concerns\WithHeadings;
use Maatwebsite\Excel\Concerns\WithStyles;
use Maatwebsite\Excel\Concerns\WithTitle;
use Maatwebsite\Excel\Concerns\ShouldAutoSize;
use Maatwebsite\Excel\Concerns\WithMultipleSheets;
use PhpOffice\PhpSpreadsheet\Worksheet\Worksheet;
use PhpOffice\PhpSpreadsheet\Style\Fill;

class ControlListReportExport implements WithMultipleSheets
{
    private array $data;

    public function __construct(array $data)
    {
        $this->data = $data;
    }

    public function sheets(): array
    {
        return [
            'Summary' => new ControlListReportSummarySheet($this->data),
            'Control List Details' => new ControlListReportDetailsSheet($this->data),
        ];
    }
}

class ControlListReportSummarySheet implements FromArray, WithHeadings, WithStyles, WithTitle, ShouldAutoSize
{
    private array $data;

    public function __construct(array $data)
    {
        $this->data = $data;
    }

    public function array(): array
    {
        return [
            ['Report Generated', $this->data['header']['generated_at']],
            ['Report Period', $this->data['header']['period']],
            ['Total Control Lists', $this->data['header']['total_control_lists']],
            [''],
            ['COMPLIANCE STATISTICS', ''],
            ['Total Control Lists', $this->data['summary']['total']],
            ['Completed Control Lists', $this->data['summary']['completed']],
            ['Pending Control Lists', $this->data['summary']['pending']],
            ['Failed Control Lists', $this->data['summary']['failed']],
            ['Compliance Rate (%)', $this->data['summary']['compliance_rate']],
            ['Average Completion Time (minutes)', $this->data['summary']['average_completion_time']],
        ];
    }

    public function headings(): array
    {
        return ['Metric', 'Value'];
    }

    public function styles(Worksheet $sheet)
    {
        return [
            1 => ['font' => ['bold' => true, 'size' => 12]],
            5 => ['font' => ['bold' => true, 'size' => 11]],
            'A:B' => ['font' => ['size' => 10]],
        ];
    }

    public function title(): string
    {
        return 'Summary';
    }
}

class ControlListReportDetailsSheet implements FromArray, WithHeadings, WithStyles, WithTitle, ShouldAutoSize
{
    private array $data;

    public function __construct(array $data)
    {
        $this->data = $data;
    }

    public function array(): array
    {
        $rows = [];
        foreach ($this->data['control_lists'] as $controlList) {
            $rows[] = [
                $controlList['id'],
                $controlList['machine_name'],
                $controlList['machine_code'],
                $controlList['assigned_user'],
                $controlList['status'],
                $controlList['created_at'],
                $controlList['completed_at'] ?? 'N/A',
                $controlList['completion_time_minutes'] ?? 'N/A',
                $controlList['items_count'],
                $controlList['completed_items'],
            ];
        }
        return $rows;
    }

    public function headings(): array
    {
        return [
            'Control List ID',
            'Machine Name',
            'Machine Code',
            'Assigned User',
            'Status',
            'Created At',
            'Completed At',
            'Completion Time (min)',
            'Total Items',
            'Completed Items',
        ];
    }

    public function styles(Worksheet $sheet)
    {
        return [
            1 => ['font' => ['bold' => true], 'fill' => ['fillType' => Fill::FILL_SOLID, 'startColor' => ['argb' => 'FFE0E0E0']]],
        ];
    }

    public function title(): string
    {
        return 'Control List Details';
    }
}