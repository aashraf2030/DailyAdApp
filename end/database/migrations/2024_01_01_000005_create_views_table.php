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
        Schema::create('views', function (Blueprint $table) {
            $table->bigIncrements('id');
            $table->uuid('ad');
            $table->uuid('user');
            $table->timestamp('time')->nullable();
            $table->decimal('points', 10, 2);
            
            $table->foreign('ad')->references('id')->on('ads')->onDelete('cascade');
            $table->foreign('user')->references('id')->on('users')->onDelete('cascade');
            
            $table->primary(['id', 'ad', 'user']);
            $table->index('ad');
            $table->index('user');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('views');
    }
};

