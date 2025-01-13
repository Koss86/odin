package snek

import rl "vendor:raylib"
import "core:fmt"

WINDOW_SIZE :: 920
CELL_SIZE :: 16
GRID_WIDTH :: 20
CANVAS_SIZE :: GRID_WIDTH*CELL_SIZE
TICK_RATE :: 0.13

Vec2i :: [2] int
snake_head_pos: Vec2i
snake_move: Vec2i
tick_timer: f32 = TICK_RATE


main :: proc() {
    
    rl.SetConfigFlags({.VSYNC_HINT})
    rl.InitWindow(WINDOW_SIZE,WINDOW_SIZE, "SnEk")
    game_start()
    camera := rl.Camera2D {
        zoom = f32(WINDOW_SIZE) / CANVAS_SIZE
    }

    for !rl.WindowShouldClose() {
        tick_timer -= rl.GetFrameTime()
        
        if tick_timer <= 0 {
            if rl.IsKeyDown(.UP) {

                if snake_move == { 0, 1 } {
                } else {
                snake_move = { 0, -1 }
                }
            } else if rl.IsKeyDown(.DOWN) {

                if snake_move == { 0, -1 } {
                } else {
                snake_move = { 0, 1 }
                }
            } else if rl.IsKeyDown(.LEFT) {

                if snake_move == { 1, 0 } {
                } else {
                snake_move = { -1, 0 }
                }
            } else if rl.IsKeyDown(.RIGHT) {
                if snake_move == { -1, 0 } {

                } else {
                snake_move = { 1, 0}
                }
            }
            snake_head_pos += snake_move
            tick_timer = TICK_RATE + tick_timer
        }

        head_rect := rl.Rectangle {
            f32(snake_head_pos.x)*CELL_SIZE, 
            f32(snake_head_pos.y)*CELL_SIZE,
            CELL_SIZE, CELL_SIZE
        }
        
        rl.BeginDrawing()
        rl.ClearBackground({76,53,83,255})
        rl.BeginMode2D(camera)                          
        
        rl.DrawRectangleRec(head_rect, rl.GREEN)

        rl.EndMode2D()
        rl.EndDrawing()
    }

    rl.CloseWindow()

}

game_start :: proc() {
    snake_head_pos = {GRID_WIDTH /2, GRID_WIDTH /2}
    
}