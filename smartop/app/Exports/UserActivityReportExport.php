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

class UserActivityReportExport implements WithMultipleSheets
{
    private array $data;

    public function __construct(array $data)
    {
        $this->data = $data;
    }

    public function sheets(): array
    {
        return [
            'Summary' => new UserActivityReportSummarySheet($this->data),
            'User Details' => new UserActivityReportDetailsSheet($this->data),
        ];
    }
}

class UserActivityReportSummarySheet implements FromArray, WithHeadings, WithStyles, WithTitle, ShouldAutoSize
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
            ['Total Users', $this->data['header']['total_users']],
            [''],
            ['ACTIVITY STATISTICS', ''],
            ['Total Users', $this->data['summary']['total_users']],
            ['Active Users', $this->data['summary']['active_users']],
            ['Total Tasks Completed', $this->data['summary']['total_tasks_completed']],
            ['Average Tasks per User', $this->data['summary']['average_tasks_per_user']],
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

class UserActivityReportDetailsSheet implements FromArray, WithHeadings, WithStyles, WithTitle, ShouldAutoSize
{
    private array $data;

    public function __construct(array $data)
    {
        $this->data = $data;
    }

    public function array(): array
    {
        $rows = [];
        foreach ($this->data['users'] as $user) {
            $rows[] = [
                $user['id'],
                $user['name'],
                $user['email'],
                $user['role'],
                $user['tasks']['total'],
                $user['tasks']['completed'],
                $user['tasks']['pending'],
                $user['tasks']['completion_rate'] . '%',
                $user['last_activity'],
            ];
        }
        return $rows;
    }

    public function headings(): array
    {
        return [
            'User ID',
            'Name',
            'Email',
            'Role',
            'Total Tasks',
            'Completed Tasks',
            'Pending Tasks',
            'Completion Rate',
            'Last Activity',
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
        return 'User Details';
    }
}