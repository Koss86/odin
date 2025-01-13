package snek

import rl "vendor:raylib"
import "core:fmt"

WINDOW_SIZE :: 920
CELL_SIZE :: 16
GRID_WIDTH :: 20
CAM_SIZE :: GRID_WIDTH*CELL_SIZE

Vec2i :: [2] int
snake_head_pos: Vec2i


main :: proc() {
    
    rl.SetConfigFlags({.VSYNC_HINT})
    rl.InitWindow(WINDOW_SIZE,WINDOW_SIZE, "SnEk")
    game_start()
    camera := rl.Camera2D {
        zoom = f32(CAM_SIZE)
    }

    for !rl.WindowShouldClose() {

        head_rect := rl.Rectangle {
            f32(snake_head_pos.x)*CELL_SIZE, 
            f32(snake_head_pos.y)*CELL_SIZE,
            CELL_SIZE, CELL_SIZE
        }

        rl.BeginMode2D(camera)
        rl.BeginDrawing()
        rl.ClearBackground({76,53,83,255})

        rl.DrawRectangleRec(head_rect, rl.GREEN)
        rl.EndMode2D()
        rl.EndDrawing()
    }

    rl.CloseWindow()

}

game_start :: proc() {
    snake_head_pos = {GRID_WIDTH /2, GRID_WIDTH /2}
    
}