package snek

import rl "vendor:raylib"
import "core:fmt"
import "core:os"

GRID_SIZE :: 20
CELL_SIZE :: 16
WINDOW_SIZE :: 920
CANVAS_SIZE :: GRID_SIZE*CELL_SIZE
TICK_RATE :: 0.11

Vec2i :: [2] int
tick_timer : f32 = TICK_RATE
snek_head_pos: Vec2i
move_snek: Vec2i


main :: proc() {

    rl.InitWindow(WINDOW_SIZE, WINDOW_SIZE, "SnEk")
    rl.SetConfigFlags({.VSYNC_HINT})

    game_state()

    camera := rl.Camera2D {
        zoom = f32(WINDOW_SIZE) / CANVAS_SIZE
    }

    for !rl.WindowShouldClose() {

        tick_timer -= rl.GetFrameTime()
        if tick_timer <= 0 {

            if rl.IsKeyDown(.UP) {
                move_snek = { 0, -1}
                snek_head_pos += move_snek
            } else if rl.IsKeyDown(.DOWN) {
                move_snek = { 0, 1 }
                snek_head_pos += move_snek
            } else if rl.IsKeyDown(.LEFT) {
                move_snek = { -1, 0 }
                snek_head_pos += move_snek
            } else if rl.IsKeyDown(.RIGHT) {
                move_snek = { 1, 0 }
                snek_head_pos += move_snek
            } else if rl.IsKeyDown(.SPACE) {
                move_snek = { 0, 0 }

            }
            

            tick_timer = TICK_RATE+tick_timer
        }

        //snek_head_pos += move_snek
        head_rect := rl.Rectangle {
            f32(snek_head_pos.x)*CELL_SIZE,
            f32(snek_head_pos.y)*CELL_SIZE,
            CELL_SIZE, CELL_SIZE
        }
        rl.BeginDrawing()
        rl.BeginMode2D(camera)
        rl.ClearBackground({76, 53, 83, 255})

        rl.DrawRectangleRec(head_rect, rl.GREEN)

        rl.EndDrawing()
        rl.EndMode2D()
    }

    rl.CloseWindow()

}

game_state :: proc() {
    snek_head_pos = { GRID_SIZE/2, GRID_SIZE/2}
    move_snek = { 0, 1}
}