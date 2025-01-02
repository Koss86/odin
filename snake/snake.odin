package snake

import rl "vendor:raylib"

WINDOW_SIZE :: 1000
GRID_WIDTH :: 20
CELL_SIZE :: 16
CANVAS_SIZE :: GRID_WIDTH*CELL_SIZE
TICK_RATE :: 0.12
Vec2i :: [2]int

tick_timer: f32 = TICK_RATE
snake_head_position: Vec2i
move_direction: Vec2i

main :: proc() {
    
    rl.SetConfigFlags({.VSYNC_HINT})
    rl.InitWindow(WINDOW_SIZE, WINDOW_SIZE, "Snake Game, Eventually")

    snake_head_position = {GRID_WIDTH / 2, GRID_WIDTH / 2}
    move_direction = {-1, 0}

    for !rl.WindowShouldClose() {

        if rl.IsKeyDown(.UP) {
            move_direction = {0, -1}  
        }
        if rl.IsKeyDown(.DOWN) {
            move_direction = {0, 1}
        }
        if rl.IsKeyDown(.LEFT) {
            move_direction = {-1, 0}
        }
        if rl.IsKeyDown(.RIGHT) {
            move_direction = {1, 0}
        }
        tick_timer -= rl.GetFrameTime()
        if tick_timer <= 0 {
            snake_head_position += move_direction
            tick_timer = TICK_RATE + tick_timer
        }

        rl.BeginDrawing()
        rl.ClearBackground({150, 150, 150, 255})

        camera := rl.Camera2D {
            zoom = f32(WINDOW_SIZE) / CANVAS_SIZE
        }
        rl.BeginMode2D(camera)

        head_rect:= rl.Rectangle {
            f32(snake_head_position.x)*CELL_SIZE,
            f32(snake_head_position.y)*CELL_SIZE,
            CELL_SIZE,
            CELL_SIZE,
        }
        rl.DrawRectangleRec(head_rect, rl.GREEN)


        
        
        rl.EndMode2D()
        rl.EndDrawing()
    }

    rl.CloseWindow()
}