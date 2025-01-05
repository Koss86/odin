package breakout

import rl "vendor:raylib"
import "core:math"

SCREEN_SIZE :: 320
PADDLE_WIDTH :: 50
PADDLE_HEIGHT :: 6
PADDLE_POS_Y :: 260
PADDLE_SPEED :: 200
BALL_SPEED :: 260
BALL_RAD :: 4
BALL_START_Y :: SCREEN_SIZE/2

paddle_pos_x: f32
ball_pos: rl.Vector2
ball_dir: rl.Vector2
started: bool

game_state :: proc() {
    paddle_pos_x = (SCREEN_SIZE/2) - (PADDLE_WIDTH/2)
    ball_pos = {SCREEN_SIZE/2, BALL_START_Y}
    started = false
}

main :: proc() {
    rl.SetConfigFlags({.VSYNC_HINT})
    rl.InitWindow(960, 960, "Breakout!")
    rl.SetTargetFPS(100)
    game_state()

    camera := rl.Camera2D {
        zoom = f32(rl.GetScreenHeight()/SCREEN_SIZE)
    }

    for !rl.WindowShouldClose() {
        
        dt: f32

        if !started {
            if rl.IsKeyPressed(.SPACE) {
                ball_dir = {0, 1}
                started = true
            } 
        } else {
            dt = rl.GetFrameTime()
        }
        paddle_move_vel: f32

        if rl.IsKeyDown(.LEFT) {
            paddle_move_vel -= PADDLE_SPEED
        }
        if rl.IsKeyDown(.RIGHT) {
            paddle_move_vel += PADDLE_SPEED
        }

        ball_pos += ball_dir * BALL_SPEED * dt
        paddle_pos_x += paddle_move_vel * dt
        paddle_pos_x = clamp(paddle_pos_x, 0, SCREEN_SIZE - PADDLE_WIDTH)
        
        rl.BeginDrawing()
        rl.ClearBackground({150, 190, 200, 255})
        rl.BeginMode2D(camera)

        paddle_rect := rl.Rectangle {
            paddle_pos_x, PADDLE_POS_Y,
            PADDLE_WIDTH, PADDLE_HEIGHT
        }
        rl.DrawRectangleRec(paddle_rect, {50, 150, 90, 255})
        rl.DrawCircleV(ball_pos, BALL_RAD, rl.RED)

        rl.EndMode2D()
        rl.EndDrawing()
    }

    rl.CloseWindow()
}