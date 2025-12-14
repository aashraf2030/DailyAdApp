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
        Schema::create('requests', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->uuid('ad')->nullable();
            $table->uuid('user');
            $table->enum('type', ['Create', 'Renew', 'Money']);
            $table->timestamp('creation')->nullable();
            $table->string('param')->nullable();
            
            $table->foreign('ad')->references('id')->on('ads')->onDelete('cascade');
            $table->foreign('user')->references('id')->on('users')->onDelete('cascade');
            $table->index('ad');
            $table->index('user');
            $table->index('type');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('requests');
    }
};

