package snek

import rl "vendor:raylib"

WINDOW_SIZE :: 1000
GRID_WIDTH :: 20
CELL_SIZE :: 16
TICK_RATE :: 0.13
CANVAS_SIZE :: GRID_WIDTH*CELL_SIZE
MAX_SNEK_LENGTH :: GRID_WIDTH*GRID_WIDTH

Vec2i :: [2]int
tick_timer: f32 = TICK_RATE
snek: [MAX_SNEK_LENGTH]Vec2i
snek_length: int
game_over: bool
move_snek: Vec2i
food_pos: Vec2i

game_start :: proc() {

    snek_length = 3
    move_snek = { 0, 1}
    snek[0] = { GRID_WIDTH / 2, GRID_WIDTH / 2 }
    snek[1] = snek[0] - { 0, 1 }
    snek[2] = snek[0] - { 0, 2 }
    game_over = false
}

main :: proc() {

    rl.SetConfigFlags({.VSYNC_HINT})
    rl.InitWindow(WINDOW_SIZE, WINDOW_SIZE, "sNeK Game")

    game_start()

    for !rl.WindowShouldClose() {

        if rl.IsKeyDown(.UP) {
            move_snek = { 0, -1 }

        } else if rl.IsKeyDown(.DOWN) {
            move_snek = { 0, 1 }

        } else if rl.IsKeyDown(.LEFT) {
            move_snek = { -1, 0 }

        } else if rl.IsKeyDown(.RIGHT) {
            move_snek = { 1, 0 }
        }

        if game_over {
            if rl.IsKeyPressed(.ENTER) {
                game_start()
            }
        } else {
           tick_timer -= rl.GetFrameTime()
        }

        

        if tick_timer <= 0 {

            next_pos := snek[0]
            snek[0] += move_snek

            if snek[0].x < 0 || snek[0].y < 0 || snek[0].x > GRID_WIDTH || snek[0].y > GRID_WIDTH {
                game_over = true
            }

            for i in 1..<snek_length {

                cur_pos := snek[i]
                snek[i] = next_pos
                next_pos = cur_pos
            }

            tick_timer = TICK_RATE + tick_timer
        }

        rl.BeginDrawing()
        rl.ClearBackground({150, 150, 150, 255})

        camera := rl.Camera2D {
            zoom = f32(WINDOW_SIZE) / CANVAS_SIZE
        }

        rl.BeginMode2D(camera)

        food_rect := rl.Rectangle {
            f32(food_pos.x)*CELL_SIZE,
            f32(food_pos.y)*CELL_SIZE,
            CELL_SIZE,
            CELL_SIZE
        }

        rl.DrawRectangleRec(food_rect, rl.RED)

        for i in 0..<snek_length {

            snek_rect := rl.Rectangle {
            f32(snek[i].x)*CELL_SIZE,
            f32(snek[i].y)*CELL_SIZE,
            CELL_SIZE,
            CELL_SIZE
            }
            rl.DrawRectangleRec(snek_rect, rl.DARKGREEN)
        }
        

        if game_over {
            rl.DrawText("Game Over", 4, 4, 25, rl.RED)
            rl.DrawText("Press Enter to try again.", 4, 30, 15, rl.BLACK)
        }

        rl.EndDrawing()
        rl.EndMode2D()
    }
    rl.CloseWindow()
}
