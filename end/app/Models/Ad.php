<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Ad extends Model
{
    use HasFactory, HasUuids;

    /**
     * The table associated with the model.
     *
     * @var string
     */
    protected $table = 'ads';

    /**
     * Indicates if the model should be timestamped.
     *
     * @var bool
     */
    public $timestamps = false;

    /**
     * Indicates if the model's ID is auto-incrementing.
     *
     * @var bool
     */
    public $incrementing = false;

    /**
     * The data type of the primary key ID.
     *
     * @var string
     */
    protected $keyType = 'string';

    /**
     * The attributes that are mass assignable.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'name',
        'path',
        'views',
        'targetViews',
        'image',
        'type',
        'category',
        'creation_date',
        'renewal_date',
        'isPublished',
        'keywords',
        'userid',
    ];

    /**
     * Get the attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'creation_date' => 'datetime',
            'renewal_date' => 'datetime',
            'isPublished' => 'boolean',
            'views' => 'integer',
            'targetViews' => 'integer',
        ];
    }

    /**
     * Get the user that owns the ad.
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class, 'userid');
    }

    /**
     * Get the requests for the ad.
     */
    public function requests(): HasMany
    {
        return $this->hasMany(Request::class, 'ad');
    }

    /**
     * Get the views for the ad.
     */
    public function views(): HasMany
    {
        return $this->hasMany(View::class, 'ad');
    }
}

