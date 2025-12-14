<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('users', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->string('fullname');
            $table->string('username')->unique();
            $table->string('password');
            $table->string('email')->unique();
            $table->string('phone')->nullable();
            $table->decimal('points', 10, 2)->default(0);
            $table->timestamp('joinDate')->nullable();
            $table->boolean('isVerified')->default(false);
            $table->boolean('isAdmin')->default(false);
            $table->boolean('isDeleted')->default(false);
            $table->string('verification');
            
            $table->index('username');
            $table->index('email');
            $table->index('isDeleted');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('users');
    }
};

