#include "mycpu.c"
#include "graphics.c"

int __errno;
float fabsf(float arg);
float sinf(float x);
float powf(float base, float exponent);

#define ArrayCount(x) (sizeof(x)/sizeof((x)[0]))

int key_a_down() {
    return *(volatile int*) 0x40000;
}

int key_b_down() {
    return *(volatile int*) 0x40004;
}

int get_high_precision_timer() {
    return *(volatile int*) 0x40100;
}

#define SCREEN_WIDTH   320
#define SCREEN_HEIGHT  240
#define PADDLE_WIDTH     4
#define PADDLE_HEIGHT   30
#define BALL_SIZE        4

#define COLOR_BG     0b01001001
#define COLOR_PADDLE COLOR_WHITE
#define COLOR_BALL   COLOR_WHITE

void DrawRect(screen_buffer Screen, int x, int y, int w, int h, u8 Color) {
    for (int dy = 0; dy < h; ++dy)
        for (int dx = 0; dx < w; ++dx)
        SetPixel(Screen, x + dx, y + dy, Color);
}

void main(void) {
    screen_buffer Screen = {
        .Width = SCREEN_WIDTH,
        .Height = SCREEN_HEIGHT,
        .PixelsPerScanline = SCREEN_WIDTH,
        .Pixels = (u8*)0x20000
    };
    
    int player_y = SCREEN_HEIGHT / 2 - PADDLE_HEIGHT / 2;
    int ai_y = SCREEN_HEIGHT / 2 - PADDLE_HEIGHT / 2;
    int ball_x = SCREEN_WIDTH / 2;
    int ball_y = SCREEN_HEIGHT / 2;
    int ball_dx = 2;
    int ball_dy = 1;
    
    int last_time = get_high_precision_timer();
    const int frame_duration_us = 1000000 / 60;
    
    // Store previous positions for erasing
    int prev_player_y = player_y;
    int prev_ai_y = ai_y;
    int prev_ball_x = ball_x;
    int prev_ball_y = ball_y;
    
    ClearScreen(Screen, COLOR_BG);
    
    while (1) {
        // Frame limiting
        
        int current_time = get_high_precision_timer();
        int elapsed = current_time - last_time;
        if (elapsed < frame_duration_us) continue;
        last_time = current_time;
        
        
        // Erase previous positions
        DrawRect(Screen, 10, prev_player_y, PADDLE_WIDTH, PADDLE_HEIGHT, COLOR_BG);
        DrawRect(Screen, SCREEN_WIDTH - 10 - PADDLE_WIDTH, prev_ai_y, PADDLE_WIDTH, PADDLE_HEIGHT, COLOR_BG);
        DrawRect(Screen, prev_ball_x, prev_ball_y, BALL_SIZE, BALL_SIZE, COLOR_BG);
        
        // Input
        if (key_a_down()) player_y -= 3;
        if (key_b_down()) player_y += 3;
        if (player_y < 0) player_y = 0;
        if (player_y > SCREEN_HEIGHT - PADDLE_HEIGHT)
            player_y = SCREEN_HEIGHT - PADDLE_HEIGHT;
        
        // AI movement
        int ai_center = ai_y + PADDLE_HEIGHT / 2;
        if (ai_center < ball_y) ai_y += 2;
        else if (ai_center > ball_y) ai_y -= 2;
        if (ai_y < 0) ai_y = 0;
        if (ai_y > SCREEN_HEIGHT - PADDLE_HEIGHT)
            ai_y = SCREEN_HEIGHT - PADDLE_HEIGHT;
        
        // Ball movement
        ball_x += ball_dx;
        ball_y += ball_dy;
        
        // Bounce top/bottom
        if (ball_y <= 0 || ball_y >= SCREEN_HEIGHT - BALL_SIZE)
            ball_dy = -ball_dy;
        
        // Collision with player
        if (ball_x <= 10 + PADDLE_WIDTH &&
            ball_y + BALL_SIZE >= player_y &&
            ball_y <= player_y + PADDLE_HEIGHT) {
            ball_dx = -ball_dx;
            ball_x = 10 + PADDLE_WIDTH;
        }
        
        // Collision with AI
        if (ball_x + BALL_SIZE >= SCREEN_WIDTH - 10 - PADDLE_WIDTH &&
            ball_y + BALL_SIZE >= ai_y &&
            ball_y <= ai_y + PADDLE_HEIGHT) {
            ball_dx = -ball_dx;
            ball_x = SCREEN_WIDTH - 10 - PADDLE_WIDTH - BALL_SIZE;
        }
        
        // Reset if out of bounds
        if (ball_x < 0 || ball_x > SCREEN_WIDTH) {
            ball_x = SCREEN_WIDTH / 2;
            ball_y = SCREEN_HEIGHT / 2;
            ball_dx = -ball_dx;
        }
        
        // Draw current positions
        DrawRect(Screen, 10, player_y, PADDLE_WIDTH, PADDLE_HEIGHT, COLOR_BLUE);
        DrawRect(Screen, SCREEN_WIDTH - 10 - PADDLE_WIDTH, ai_y, PADDLE_WIDTH, PADDLE_HEIGHT, COLOR_PADDLE);
        DrawRect(Screen, ball_x, ball_y, BALL_SIZE, BALL_SIZE, COLOR_RED);
        
        // Save positions for next frame erase
        prev_player_y = player_y;
        prev_ai_y = ai_y;
        prev_ball_x = ball_x;
        prev_ball_y = ball_y;
    }
}
