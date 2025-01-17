package snek

import rl "vendor:raylib"
import "core:fmt"
import "core:os"

WINDOW_SIZE :: 920
GRID_WIDTH :: 20
CELL_SIZE :: 16
CANVAS_SIZE :: GRID_WIDTH*CELL_SIZE
MAX_SNEK_LENGTH :: GRID_WIDTH*GRID_WIDTH
TICK_RATE :: 0.13

Vec2i :: [2] int

snek: [MAX_SNEK_LENGTH] Vec2i
move_snek: Vec2i
tick_timer : f32 = TICK_RATE
snek_leng: int
game_over: bool
food_pos: Vec2i


main :: proc() {

    rl.InitWindow(WINDOW_SIZE, WINDOW_SIZE, "SNEK")
    rl.SetConfigFlags({.VSYNC_HINT})

    game_state()

    camera := rl.Camera2D {
        zoom = f32(WINDOW_SIZE) / CANVAS_SIZE
    }

    for !rl.WindowShouldClose() {

        tick_timer -= rl.GetFrameTime()

        if tick_timer <= 0 {

            if rl.IsKeyDown(.UP) {
                if move_snek == { 0, 1 } {
                    //do nothing, no back tracking!
                } else {
                    move_snek = { 0, -1 }
                }
            }
            if rl.IsKeyDown(.DOWN) {
                if move_snek == { 0, -1 } {
                    //do nothing, no back tracking!
                } else {
                    move_snek = { 0, 1 }
                }
            }
            if rl.IsKeyDown(.LEFT) {
                if move_snek == { 1, 0 } {
                    //do nothing, no back tracking!
                } else {
                    move_snek = { -1, 0 }
                }
            }
            if rl.IsKeyDown(.RIGHT) {
                if move_snek == { -1, 0 } {
                    //do nothing, no back tracking!
                } else {
                    move_snek = { 1, 0 }
                }
            }

            nxt_pos := snek[0]
            snek[0] += move_snek

            if snek[0].x < 0 || snek[0].x >= GRID_WIDTH ||
               snek[0].y < 0 || snek[0].y >= GRID_WIDTH {
                game_over = true
               }

            for i in 1..<snek_leng {
                cur_pos := snek[i]
                snek[i] = nxt_pos
                nxt_pos = cur_pos
            }
            if game_over {
                rl.DrawText("Game Over", 350, 100, 45, rl.RED)
                rl.DrawText("Press Enter to play again!", 300, 150, 25, {175, 175, 175, 255})
                if rl.IsKeyPressed(.ENTER) {
                    tick_timer = TICK_RATE + tick_timer
                    game_state()
                }
            }else {
                tick_timer = TICK_RATE + tick_timer   
            }
            
        }

        rl.ClearBackground({0, 128, 200, 255})
        rl.BeginDrawing()
        rl.BeginMode2D(camera)
        
        food_rect := rl.Rectangle {
            f32(food_pos.x)*CELL_SIZE,
            f32(food_pos.y)*CELL_SIZE,
            CELL_SIZE, CELL_SIZE }

            rl.DrawRectangleRec(food_rect, rl.RED)

        for i in 0..<snek_leng {
            snek_part_rect := rl.Rectangle {
                f32(snek[i].x*CELL_SIZE),
                f32(snek[i].y*CELL_SIZE),
                CELL_SIZE, CELL_SIZE }

            rl.DrawRectangleRec(snek_part_rect, { 190, 80, 0, 255 })
        }
        rl.EndMode2D()
        rl.EndDrawing()
    }

    rl.CloseWindow()
}

game_state :: proc() {

    move_snek = { 0, 1 }
    snek[0] = { GRID_WIDTH /2, 5 }
    snek[1] = (snek[0] - {0, 1})
    snek[2] = (snek[0] - {0, 2})
    snek_leng = 3
    game_over = false
}

place_food :: proc() {

    ouccupied: [GRID_WIDTH] [GRID_WIDTH] bool
    for i in 0..<snek_leng {
        ouccupied[snek[i].x] [snek[i].y] = true
    }

    free_cells := make([dynamic] Vec2i, context.temp_allocator)

    for x in 0..<GRID_WIDTH {
        for y in 0..<GRID_WIDTH {
            if !ouccupied[x][y] {
                append(&free_cells, Vec2i {x, y})
            }
        }
    }
}