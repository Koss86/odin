package snek

import rl "vendor:raylib"

WINDOW_SIZE :: 920
GRID_WIDTH :: 20
CELL_SIZE :: 16
CANVAS_SIZE :: GRID_WIDTH*CELL_SIZE
TICK_RATE :: 0.12
MAX_SNEK_LENGTH :: GRID_WIDTH*GRID_WIDTH

Vec2i :: [2] int

snek:[MAX_SNEK_LENGTH] Vec2i
move_snek: Vec2i
food_pos: Vec2i
tick_timer : f32 = TICK_RATE
snek_leng: int
game_over: bool

main :: proc() {

    rl.InitWindow(WINDOW_SIZE, WINDOW_SIZE, "SNEK")
    rl.SetConfigFlags({.VSYNC_HINT})
    game_setup()
    camera := rl.Camera2D {
        zoom = f32(WINDOW_SIZE) / CANVAS_SIZE }

    for !rl.WindowShouldClose() {

        if rl.IsKeyDown(.UP) {
            if move_snek == { 0, 1 } {

            } else {
                move_snek = { 0, -1 }
            }
        }
        if rl.IsKeyDown(.DOWN) {
            if move_snek == { 0, -1 } {

            } else {
                move_snek = { 0, 1 }
            }
        }
        if rl.IsKeyDown(.LEFT) {
            if move_snek == { 1, 0 } {

            } else {
                move_snek = { -1, 0 }
            }
        }
        if rl.IsKeyDown(.RIGHT) {
            if move_snek == { -1, 0 } {

            } else {
                move_snek = { 1, 0 }
            }
        }

        tick_timer -= rl.GetFrameTime()

        if tick_timer <= 0 {
            nxt_pos := snek[0]
            snek[0] += move_snek

            if snek[0].x < 0 || snek[0].y < 0 ||
               snek[0].x >= GRID_WIDTH || snek[0].y >= GRID_WIDTH {

                game_over = true
               }
            
            if snek[0] == food_pos {
                place_food()
                snek_leng += 1
            }

            for i in 1..<snek_leng {
                cur_pos := snek[i]
                snek[i] = nxt_pos
                nxt_pos = cur_pos
                if snek[0] == cur_pos {
                    game_over = true
                }
            }

            if game_over {
                rl.DrawText("Game Over", 250, 90, 50, rl.RED)
                if rl.IsKeyPressed(.ENTER) {
                    game_setup()
                }
            } else {
                tick_timer = TICK_RATE + tick_timer
 
            }
        }

        rl.ClearBackground(rl.BLACK)
        rl.BeginDrawing()
        rl.BeginMode2D(camera)

        food_rect := rl.Rectangle {
            f32(food_pos.x)*CELL_SIZE,
            f32(food_pos.y)*CELL_SIZE,
            CELL_SIZE, CELL_SIZE }

        rl.DrawRectangleRec(food_rect, rl.RED)

        for i in 0..<snek_leng {

            snek_part_rect := rl.Rectangle {
                f32(snek[i].x)*CELL_SIZE,
                f32(snek[i].y)*CELL_SIZE,
                CELL_SIZE, CELL_SIZE }

            rl.DrawRectangleRec(snek_part_rect, rl.GREEN)
        }

        free_all(context.temp_allocator)
        rl.EndMode2D()
        rl.EndDrawing()
    }
    rl.CloseWindow()
}

game_setup :: proc() {

    snek[0] = { GRID_WIDTH / 2, 5 }
    snek[1] = snek[0] - { 0, 1 }
    snek[2] = snek[0] - { 0, 2 }
    move_snek = { 0, 1 }
    snek_leng = 3
    game_over = false
    place_food()
}

place_food :: proc() {

    occupied: [GRID_WIDTH] [GRID_WIDTH] bool

    for i in 0..<snek_leng {
        occupied [snek[i].x] [snek[i].y] = true
    }

    free_cells := make( [dynamic] Vec2i, context.temp_allocator )
    
    for x in 0..<GRID_WIDTH {
        for y in 0..<GRID_WIDTH {
            if !occupied[x][y] {
                append(&free_cells, Vec2i { x, y })
            }
        }
    }
    rand := rl.GetRandomValue(0, i32(len(free_cells))-1)
    food_pos = free_cells [rand]
}