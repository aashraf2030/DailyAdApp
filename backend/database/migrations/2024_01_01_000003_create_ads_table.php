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
        Schema::create('ads', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->string('name');
            $table->string('path');
            $table->integer('views')->default(0);
            $table->integer('targetViews');
            $table->string('image');
            $table->enum('type', ['Fixed', 'Dynamic']);
            $table->enum('category', [
                'Electronics',
                'Fashion',
                'Health',
                'Home',
                'Groceries',
                'Games',
                'Books',
                'Automotive',
                'Pet',
                'Food',
                'Other'
            ]);
            $table->timestamp('creation_date')->nullable();
            $table->timestamp('renewal_date')->nullable();
            $table->boolean('isPublished')->default(false);
            $table->text('keywords');
            $table->uuid('userid');
            
            $table->foreign('userid')->references('id')->on('users')->onDelete('cascade');
            $table->index('userid');
            $table->index('type');
            $table->index('category');
            $table->index('isPublished');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('ads');
    }
};

