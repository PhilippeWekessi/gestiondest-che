<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Task extends Model
{
    protected $fillable = ['title', 'content', 'date_time', 'priority'];

    protected $casts = [
        'date_time' => 'datetime',
    ];
}