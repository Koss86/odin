package snake

import rl "vendor:raylib"

WINDOW_SIZE :: 1000
GRID_WIDTH :: 20
CELL_SIZE :: 16
CANVAS_SIZE :: GRID_WIDTH*CELL_SIZE
TICK_RATE :: 0.13
MAX_SNAKE_LENGTH :: GRID_WIDTH*GRID_WIDTH
Vec2i :: [2]int

tick_timer: f32 = TICK_RATE
move_direction: Vec2i
snake: [MAX_SNAKE_LENGTH]Vec2i
snake_length: int
game_over: bool

restart :: proc() {
    start_head_pos := Vec2i {GRID_WIDTH / 2, GRID_WIDTH / 2}
    snake[0] = start_head_pos
    snake[1] = start_head_pos - {0,1}
    snake[2] = start_head_pos - {0,2}
    snake_length = 3
    move_direction = {0, -1}
    game_over = false
}

main :: proc() {
    
    rl.SetConfigFlags({.VSYNC_HINT})
    rl.InitWindow(WINDOW_SIZE, WINDOW_SIZE, "Snake Game, Eventually")

    restart()

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

        if game_over {
            if rl.IsKeyPressed(.ENTER) {
                restart()
            }
            
        } else {

            tick_timer -= rl.GetFrameTime()
        }

        if tick_timer <= 0 {

            next_part_pos:= snake[0]
            snake[0] += move_direction

            if snake[0].x < 0 || snake[0].y < 0 || snake[0].x >= GRID_WIDTH || snake[0].y >= GRID_WIDTH {

                game_over = true
            }

            for i in 1..<snake_length {
                cur_pos:= snake[i]
                snake[i] = next_part_pos
                next_part_pos = cur_pos
            }
            tick_timer = TICK_RATE + tick_timer
        }

        rl.BeginDrawing()

        rl.ClearBackground({150, 150, 150, 255})

        camera:= rl.Camera2D {

            zoom = f32(WINDOW_SIZE) / CANVAS_SIZE
        }
        rl.BeginMode2D(camera)

        for i in 0..<snake_length {

            part_rect:= rl.Rectangle {

                f32(snake[i].x)*CELL_SIZE,
                f32(snake[i].y)*CELL_SIZE,
                CELL_SIZE,
                CELL_SIZE,
            }

            rl.DrawRectangleRec(part_rect, rl.DARKGREEN)
        }
        rl.EndMode2D()
        rl.EndDrawing()
    }

    rl.CloseWindow()
}