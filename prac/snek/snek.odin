package snek_game

import rl "vendor:raylib"
import "core:math"
import "core:fmt"

WINDOW_SIZE :: 920
GRID_WIDTH :: 20
CELL_SIZE :: 16
TICK_RATE :: 0.13
CANVAS_SIZE :: GRID_WIDTH*CELL_SIZE
SNEK_MAX_LENG :: GRID_WIDTH*GRID_WIDTH

Vec2 :: [2] int
move_snek: Vec2
snek_leng: int
food_pos: Vec2
snek: [SNEK_MAX_LENG] Vec2

main :: proc() {
    tick_timer: f32 = TICK_RATE
    rl.InitWindow(WINDOW_SIZE, WINDOW_SIZE, "Snek")
    rl.SetConfigFlags({.VSYNC_HINT})
    rl.SetTargetFPS(60)

    game_state()
    camera := rl.Camera2D {
        zoom = f32(WINDOW_SIZE)/CANVAS_SIZE
    }
    for !rl.WindowShouldClose() {

        if rl.IsKeyDown(.UP) {
            if move_snek == { 0, 1 } {

            } else {
                move_snek = { 0, -1 }
            }
        } else if rl.IsKeyDown(.DOWN) {
            if move_snek == { 0, -1 } {

            } else {
                move_snek = { 0, 1 }
            }
        } else if rl.IsKeyDown(.LEFT) {
            if move_snek == { 1, 0} {

            } else {
                move_snek = { -1, 0 }
            }
        } else if rl.IsKeyDown(.RIGHT) {
            if move_snek == { -1, 0 } {

            } else {
                move_snek = { 1, 0 }
            }
        }

        tick_timer -= rl.GetFrameTime()

        if tick_timer <= 0 {
            nxt_pos := snek[0]
            snek[0] += move_snek

            for i in 1..<snek_leng {
                cur_pos := snek[i]
                snek[i] = nxt_pos
                nxt_pos = cur_pos
            }

            tick_timer = TICK_RATE + tick_timer
        }

        rl.ClearBackground(rl.BLACK)
        rl.BeginDrawing()
        rl.BeginMode2D(camera)

        for i in 0..<snek_leng {
            rect:= rl.Rectangle {
                f32(snek[i].x)* CELL_SIZE,
                f32(snek[i].y )* CELL_SIZE,
                CELL_SIZE, CELL_SIZE
            }

            rl.DrawRectangleRec(rect, rl.GREEN)
        }
        





        rl.EndMode2D()
        rl.EndDrawing()
    }

    rl.CloseWindow()
}

game_state :: proc() {
    move_snek = { 0, -1 }
    snek[0] = {GRID_WIDTH /2, GRID_WIDTH /2}
    snek[1] = snek[0] - { 0, 1 }
    snek[2] = snek[0] - { 0, 2 }
    snek_leng = 3
}

place_food :: proc() {

    occupied: [GRID_WIDTH] [GRID_WIDTH] bool

    for i in 0..<snek_leng {
        occupied [snek[i].x] [snek[i].y] = true
    }

    free_cells := make([dynamic] Vec2, context.temp_allocator)

    for x in 0..<GRID_WIDTH {
        for y in 0..<GRID_WIDTH {
            if !occupied[x][y] {
                append(&free_cells, Vec2 { x, y })
            }
        }
    }
}