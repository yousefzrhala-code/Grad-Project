<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Admin\AdminController;
use App\Models\Report;

class AdminReportController extends AdminController
{
    public function index()
    {
        $this->checkAdmin();

        $reports = Report::with(['user:id,name,email', 'garage:id,name,city'])
            ->latest()
            ->get();

        return view('admin.reports.index', compact('reports'));
    }

    public function markReviewed($id)
    {
        $this->checkAdmin();

        $report = Report::findOrFail($id);
        $report->status = 'reviewed';
        $report->save();

        return back()->with('success', 'Report marked as reviewed');
    }

    public function markResolved($id)
    {
        $this->checkAdmin();

        $report = Report::findOrFail($id);
        $report->status = 'resolved';
        $report->save();

        return back()->with('success', 'Report marked as resolved');
    }

    public function delete($id)
    {
        $this->checkAdmin();

        $report = Report::findOrFail($id);
        $report->delete();

        return back()->with('success', 'Report deleted');
    }
}
