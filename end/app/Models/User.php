<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use PHPOpenSourceSaver\JWTAuth\Contracts\JWTSubject;

class User extends Authenticatable implements JWTSubject
{
    use HasFactory, Notifiable, HasUuids;

    /**
     * Indicates if the model should use timestamps.
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
        'fullname',
        'username',
        'email',
        'password',
        'phone',
        'points',
        'joinDate',
        'isVerified',
        'isAdmin',
        'isDeleted',
        'verification',
    ];

    /**
     * The attributes that should be hidden for serialization.
     *
     * @var array<int, string>
     */
    protected $hidden = [
        'password',
        'verification',
    ];

    /**
     * Get the attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'joinDate' => 'datetime',
            'isVerified' => 'boolean',
            'isAdmin' => 'boolean',
            'isDeleted' => 'boolean',
            'points' => 'decimal:2',
            // Note: password is stored as SHA-256 hash (from Flutter), not bcrypt
            // 'password' => 'hashed', // Removed - Flutter sends SHA-256 hash
        ];
    }

    /**
     * Get the identifier that will be stored in the subject claim of the JWT.
     *
     * @return mixed
     */
    public function getJWTIdentifier()
    {
        return $this->getKey();
    }

    /**
     * Return a key value array, containing any custom claims to be added to the JWT.
     *
     * @return array
     */
    public function getJWTCustomClaims()
    {
        return [
            'username' => $this->username,
            'isAdmin' => $this->isAdmin,
            'isVerified' => $this->isVerified,
        ];
    }

    /**
     * Get the ads for the user.
     */
    public function ads(): HasMany
    {
        return $this->hasMany(Ad::class, 'userid');
    }

    /**
     * Get the sessions for the user.
     */
    public function sessions(): HasMany
    {
        return $this->hasMany(Session::class, 'userid');
    }

    /**
     * Get the requests for the user.
     */
    public function requests(): HasMany
    {
        return $this->hasMany(Request::class, 'user');
    }

    /**
     * Get the views for the user.
     */
    public function views(): HasMany
    {
        return $this->hasMany(View::class, 'user');
    }
}
