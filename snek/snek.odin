package snek

import rl "vendor:raylib"

WINDOW_SIZE :: 1000
CANVAS_SIZE :: 320
GRID_SIZE :: 20
CELL_SIZE :: 16
TICK_RATE :: 0.13

Vec2i :: [2]int

snek_head_pos: Vec2i

main :: proc() {
    rl.SetConfigFlags({.VSYNC_HINT})
    rl.SetTargetFPS(100)
    rl.InitWindow(WINDOW_SIZE, WINDOW_SIZE, "sNeK Game")

    set_game_state()
    camera := rl.Camera2D {
        zoom = f32(WINDOW_SIZE)/CANVAS_SIZE
    }
    move_snek := Vec2i { 0, 1 }
    tick_timer: f32 = TICK_RATE

    for !rl.WindowShouldClose() {

        tick_timer -= rl.GetFrameTime()
        if rl.IsKeyDown(.UP) {
            move_snek = { 0, -1}
        }
        if rl.IsKeyDown(.DOWN) {
            move_snek = { 0, 1}
        }
        if rl.IsKeyDown(.LEFT) {
            move_snek = { -1, 0 }
        }
        if rl.IsKeyDown(.RIGHT) {
            move_snek = { 1, 0}
        }
        snek_head_pos += move_snek


        head_rect := rl.Rectangle {
            f32(snek_head_pos.x*CELL_SIZE),
            f32(snek_head_pos.y*CELL_SIZE),
            CELL_SIZE, CELL_SIZE
        }
        tick_timer = TICK_RATE + tick_timer
        
        rl.BeginDrawing()
        rl.ClearBackground(rl.BLACK)
        rl.BeginMode2D(camera)

        if tick_timer <= 0 {
            rl.DrawRectangleRec(head_rect, rl.GREEN)

            tick_timer = TICK_RATE + tick_timer
        }
        
        rl.EndMode2D()
        rl.EndDrawing()
    }

    rl.CloseWindow()
}

set_game_state :: proc() {
    snek_head_pos = { GRID_SIZE/2, GRID_SIZE/2 }
}