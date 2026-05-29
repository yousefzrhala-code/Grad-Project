<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Admin\AdminController;
use App\Models\ContactMessage;

class AdminContactController extends AdminController
{
    public function index()
    {
        $this->checkAdmin();

        $messages = ContactMessage::latest()->get();

        return view('admin.contact_messages.index', compact('messages'));
    }

    public function markReplied($id)
    {
        $this->checkAdmin();

        $message = ContactMessage::findOrFail($id);
        $message->status = 'replied';
        $message->save();

        return back()->with('success', 'Message marked as replied');
    }

    public function delete($id)
    {
        $this->checkAdmin();

        ContactMessage::findOrFail($id)->delete();

        return back()->with('success', 'Message deleted successfully');
    }
}
