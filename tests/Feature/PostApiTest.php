<?php

namespace Tests\Feature;

use App\Models\Post;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class PostApiTest extends TestCase
{
    use RefreshDatabase;

    // ==================== POST /api/posts ====================

    public function test_can_create_post_successfully(): void
    {
        // Arrange
        $data = [
            'title' => 'Test Post Title',
            'content' => 'This is test content for the post',
            'excerpt' => 'Test excerpt',
            'status' => 'published',
            'featured' => true,
            'published_at' => now(),
        ];

        // Act
        $response = $this->postJson('/api/posts', $data);

        // Assert
        $response->assertStatus(201);

        $this->assertDatabaseHas('posts', [
            'title' => 'Test Post Title',
        ]);
    }

    public function test_fails_when_title_is_empty(): void
    {
        $response = $this->postJson('/api/posts', [
            'content' => 'Test content',
            'status' => 'published',
        ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['title']);
    }

    public function test_fails_when_content_is_empty(): void
    {
        $response = $this->postJson('/api/posts', [
            'title' => 'Test Title',
            'status' => 'published',
        ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['content']);
    }

    // ==================== GET /api/posts ====================

    public function test_can_list_all_posts(): void
    {
        Post::factory()->count(3)->create();

        $response = $this->getJson('/api/posts');

        $response->assertStatus(200)
            ->assertJsonCount(3, 'data');
    }

    public function test_returns_empty_array_when_no_posts(): void
    {
        $response = $this->getJson('/api/posts');

        $response->assertStatus(200)
            ->assertJsonCount(0, 'data');
    }

    // ==================== GET /api/posts/{id} ====================

    public function test_can_show_single_post(): void
    {
        $post = Post::factory()->create();

        $response = $this->getJson("/api/posts/{$post->id}");

        $response->assertStatus(200)
            ->assertJsonFragment(['id' => $post->id]);
    }

    public function test_returns_404_when_post_not_found(): void
    {
        $response = $this->getJson('/api/posts/99999');

        $response->assertStatus(404);
    }

    // ==================== PUT /api/posts/{id} ====================

    public function test_can_update_post_successfully(): void
    {
        $post = Post::factory()->create([
            'title' => 'Original Title',
        ]);

        $response = $this->putJson("/api/posts/{$post->id}", [
            'title' => 'Updated Title',
            'content' => 'Updated content',
            'status' => 'draft',
        ]);

        $response->assertStatus(200);

        $this->assertDatabaseHas('posts', [
            'id' => $post->id,
            'title' => 'Updated Title',
        ]);
    }

    public function test_fails_update_when_post_not_exists(): void
    {
        $response = $this->putJson('/api/posts/99999', [
            'title' => 'Updated Title',
            'content' => 'Updated content',
            'status' => 'published',
        ]);

        $response->assertStatus(404);
    }

    // ==================== DELETE /api/posts/{id} ====================

    public function test_can_delete_post_successfully(): void
    {
        $post = Post::factory()->create();

        $response = $this->deleteJson("/api/posts/{$post->id}");

        $response->assertStatus(200);

        $this->assertDatabaseMissing('posts', [
            'id' => $post->id,
        ]);
    }

    public function test_fails_delete_when_post_not_found(): void
    {
        $response = $this->deleteJson('/api/posts/99999');

        $response->assertStatus(404);
    }

    // ==================== Validation Tests ====================

    public function test_fails_when_status_is_invalid(): void
    {
        $response = $this->postJson('/api/posts', [
            'title' => 'Test Title',
            'content' => 'Test content',
            'status' => 'invalid_status',
        ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['status']);
    }

    public function test_accepts_nullable_excerpt(): void
    {
        $data = [
            'title' => 'Test Post',
            'content' => 'Test content',
            'status' => 'published',
        ];

        $response = $this->postJson('/api/posts', $data);

        $response->assertStatus(201);
    }
}
