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
use PhpOffice\PhpSpreadsheet\Style\Font;

class MachineReportExport implements WithMultipleSheets
{
    private array $data;

    public function __construct(array $data)
    {
        $this->data = $data;
    }

    public function sheets(): array
    {
        return [
            'Summary' => new MachineReportSummarySheet($this->data),
            'Machine Details' => new MachineReportDetailsSheet($this->data),
        ];
    }
}

class MachineReportSummarySheet implements FromArray, WithHeadings, WithStyles, WithTitle, ShouldAutoSize
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
            ['Total Machines', $this->data['header']['total_machines']],
            [''],
            ['SUMMARY STATISTICS', ''],
            ['Total Control Lists', $this->data['summary']['total_control_lists']],
            ['Completed Control Lists', $this->data['summary']['completed_control_lists']],
            ['Pending Control Lists', $this->data['summary']['pending_control_lists']],
            ['Failed Control Lists', $this->data['summary']['failed_control_lists']],
            ['Average Completion Rate (%)', $this->data['summary']['average_completion_rate']],
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

class MachineReportDetailsSheet implements FromArray, WithHeadings, WithStyles, WithTitle, ShouldAutoSize
{
    private array $data;

    public function __construct(array $data)
    {
        $this->data = $data;
    }

    public function array(): array
    {
        $rows = [];
        foreach ($this->data['machines'] as $machine) {
            $rows[] = [
                $machine['id'],
                $machine['name'],
                $machine['code'],
                $machine['type'],
                $machine['location'],
                $machine['status'],
                $machine['control_lists']['total'],
                $machine['control_lists']['completed'],
                $machine['control_lists']['pending'],
                $machine['control_lists']['failed'],
                $machine['control_lists']['completion_rate'] . '%',
                $machine['last_maintenance'] ?? 'N/A',
                $machine['next_maintenance'] ?? 'N/A',
            ];
        }
        return $rows;
    }

    public function headings(): array
    {
        return [
            'Machine ID',
            'Machine Name',
            'Machine Code',
            'Type',
            'Location',
            'Status',
            'Total Control Lists',
            'Completed',
            'Pending',
            'Failed',
            'Completion Rate',
            'Last Maintenance',
            'Next Maintenance',
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
        return 'Machine Details';
    }
}