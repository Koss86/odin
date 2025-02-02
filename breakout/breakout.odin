package breakout

import rl "vendor:raylib"
import "core:math"
import "core:math/linalg"

WINDOW_SIZE :: 960
CANVAS_SIZE :: 320
PADDLE_WIDTH :: 50
PADDLE_HEIGHT :: 6
PADDLE_POS_Y :: 260
PADDLE_SPEED :: 200
Vec2 :: rl.Vector2
paddle_pos_x: f32

main :: proc() {
    rl.SetConfigFlags({.VSYNC_HINT})
    rl.InitWindow(WINDOW_SIZE, WINDOW_SIZE, "Breakout!")
    //rl.SetTargetFPS(500)
    camera := rl.Camera2D {
        zoom = f32(WINDOW_SIZE)/CANVAS_SIZE
    }
    start()
    for !rl.WindowShouldClose() {
        move_pad: f32
        dt := rl.GetFrameTime()

        if rl.IsKeyDown(.LEFT) {
            move_pad -= PADDLE_SPEED
        }
        if rl.IsKeyDown(.RIGHT) {
            move_pad += PADDLE_SPEED
        }

        paddle_pos_x += move_pad * dt
        paddle_pos_x = clamp(paddle_pos_x, 0, CANVAS_SIZE-PADDLE_WIDTH)

        rl.BeginDrawing()
            rl.BeginMode2D(camera)
            rl.ClearBackground({ 150, 190, 220, 255 })

            paddle_rect := rl.Rectangle {
                paddle_pos_x, PADDLE_POS_Y,
                PADDLE_WIDTH, PADDLE_HEIGHT
            }
            rl.DrawRectangleRec(paddle_rect, rl.RED)

            rl.EndMode2D()
        rl.EndDrawing()
    }
    rl.CloseWindow()
}
start :: proc() {
    paddle_pos_x = CANVAS_SIZE/2 - PADDLE_WIDTH/2
}