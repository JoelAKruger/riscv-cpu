#include "mycpu.c"
#include "graphics.c"

int __errno;
float fabsf(float arg);
float sinf(float x);
float powf(float base, float exponent);

#define ArrayCount(x) (sizeof(x)/sizeof((x)[0]))

typedef struct
{
    f32 Curvature;
    f32 Distance;
} game_track_section;

int key_a_down()
{
    return *(volatile int*) 0x100000;
}

int key_b_down()
{
    return *(volatile int*) 0x100004;
}

int get_high_precision_timer()
{
    return *(volatile int*) 0x100100;
}

#define SCREEN_WIDTH  320
#define SCREEN_HEIGHT 240
#define PADDLE_WIDTH   4
#define PADDLE_HEIGHT 30
#define BALL_SIZE      4

#define COLOR_BG    COLOR_BLACK
#define COLOR_PADDLE COLOR_WHITE
#define COLOR_BALL   COLOR_WHITE

void main(void)
{
	screen_buffer Screen = {
		.Width = 320,
		.Height = 240,
		.PixelsPerScanline = 320,
		.Pixels = (u8*)0x20000
	};
    
    int player_y = SCREEN_HEIGHT / 2 - PADDLE_HEIGHT / 2;
    int ai_y = SCREEN_HEIGHT / 2 - PADDLE_HEIGHT / 2;
    int ball_x = SCREEN_WIDTH / 2;
    int ball_y = SCREEN_HEIGHT / 2;
    int ball_dx = 2;
    int ball_dy = 1;
    
    const int frame_duration_us = 1000000 / 60; // 60 fps = ~16666 µs
    int last_time = get_high_precision_timer();
    
    while (1) {
        int current_time = get_high_precision_timer();
        int elapsed = current_time - last_time;
        
        if (elapsed < frame_duration_us) {
            continue; // busy-wait
        }
        
        last_time = current_time;
        
        // Erase screen
        for (int y = 0; y < SCREEN_HEIGHT; ++y)
            for (int x = 0; x < SCREEN_WIDTH; ++x)
            SetPixel(Screen, x, y, COLOR_BG);
        
        // Input (player)
        if (key_a_down()) player_y -= 3;
        if (key_b_down()) player_y += 3;
        if (player_y < 0) player_y = 0;
        if (player_y > SCREEN_HEIGHT - PADDLE_HEIGHT)
            player_y = SCREEN_HEIGHT - PADDLE_HEIGHT;
        
        // AI Movement
        int ai_center = ai_y + PADDLE_HEIGHT / 2;
        if (ai_center < ball_y) ai_y += 2;
        else if (ai_center > ball_y) ai_y -= 2;
        if (ai_y < 0) ai_y = 0;
        if (ai_y > SCREEN_HEIGHT - PADDLE_HEIGHT)
            ai_y = SCREEN_HEIGHT - PADDLE_HEIGHT;
        
        // Ball movement
        ball_x += ball_dx;
        ball_y += ball_dy;
        
        // Ball bounce (top/bottom)
        if (ball_y <= 0 || ball_y >= SCREEN_HEIGHT - BALL_SIZE)
            ball_dy = -ball_dy;
        
        // Ball bounce (player paddle)
        if (ball_x <= 10 + PADDLE_WIDTH &&
            ball_y + BALL_SIZE >= player_y &&
            ball_y <= player_y + PADDLE_HEIGHT) {
            ball_dx = -ball_dx;
            ball_x = 10 + PADDLE_WIDTH;
        }
        
        // Ball bounce (AI paddle)
        if (ball_x + BALL_SIZE >= SCREEN_WIDTH - 10 - PADDLE_WIDTH &&
            ball_y + BALL_SIZE >= ai_y &&
            ball_y <= ai_y + PADDLE_HEIGHT) {
            ball_dx = -ball_dx;
            ball_x = SCREEN_WIDTH - 10 - PADDLE_WIDTH - BALL_SIZE;
        }
        
        // Ball out of bounds (reset to center)
        if (ball_x < 0 || ball_x > SCREEN_WIDTH) {
            ball_x = SCREEN_WIDTH / 2;
            ball_y = SCREEN_HEIGHT / 2;
            ball_dx = -ball_dx;
        }
        
        // Draw player paddle
        for (int y = 0; y < PADDLE_HEIGHT; ++y)
            for (int x = 0; x < PADDLE_WIDTH; ++x)
            SetPixel(Screen, 10 + x, player_y + y, COLOR_BLUE);
        
        // Draw AI paddle
        for (int y = 0; y < PADDLE_HEIGHT; ++y)
            for (int x = 0; x < PADDLE_WIDTH; ++x)
            SetPixel(Screen, SCREEN_WIDTH - 10 - PADDLE_WIDTH + x, ai_y + y, COLOR_PADDLE);
        
        // Draw ball
        for (int y = 0; y < BALL_SIZE; ++y)
            for (int x = 0; x < BALL_SIZE; ++x)
            SetPixel(Screen, ball_x + x, ball_y + y, COLOR_RED);
    }
}