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
        Schema::create('conversations', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->uuid('user_id'); // User who started the conversation
            $table->uuid('admin_id')->nullable(); // Admin who is handling (null if not assigned yet)
            $table->string('subject')->nullable(); // Optional subject/title
            $table->boolean('is_active')->default(true); // Whether conversation is active
            $table->timestamp('last_message_at')->nullable(); // Last message timestamp
            $table->integer('unread_count_user')->default(0); // Unread messages count for user
            $table->integer('unread_count_admin')->default(0); // Unread messages count for admin
            $table->timestamp('created_at')->useCurrent();
            $table->timestamp('updated_at')->useCurrent()->useCurrentOnUpdate();
            
            $table->foreign('user_id')->references('id')->on('users')->onDelete('cascade');
            $table->foreign('admin_id')->references('id')->on('users')->onDelete('set null');
            $table->index('user_id');
            $table->index('admin_id');
            $table->index('is_active');
            $table->index('last_message_at');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('conversations');
    }
};

