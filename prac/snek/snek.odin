package snek

import rl "vendor:raylib"
import "core:fmt"
import "core:os"

WINDOW_SIZE :: 920
GRID_SIZE :: 20
CELL_SIZE :: 16
CANVAS_SIZE :: GRID_SIZE*CELL_SIZE
TICK_RATE :: 0.0325
MAX_SNEK_LENGTH :: GRID_SIZE*GRID_SIZE

Vec2i :: [2] f32

move_snek: Vec2i
snek_head_pos: Vec2i
tick_timer : f32 = TICK_RATE
player_start: bool

main :: proc() {
    
    rl.SetConfigFlags({.VSYNC_HINT})
    rl.InitWindow(WINDOW_SIZE, WINDOW_SIZE, "sNeK")
    rl.SetTargetFPS(60)

    init_game_state()

    camera := rl.Camera2D { zoom = f32(WINDOW_SIZE)/CANVAS_SIZE }

    head_rect:= rl.Rectangle {
        snek_head_pos.x*CELL_SIZE,
        snek_head_pos.y*CELL_SIZE,
        CELL_SIZE, CELL_SIZE
    }

    for !rl.WindowShouldClose() {

        tick_timer -= rl.GetFrameTime()

        if tick_timer <= 0 {

            if rl.IsKeyDown(.UP) {
                if move_snek == { 0, .25 } {
                    // do nothing.
                } else {
                move_snek = { 0, -.25 }
                player_start = true
                }
            } else if rl.IsKeyDown(.DOWN) { 
                if move_snek == { 0, -.25 } { 
                    // do nothing.
                } else { 
                move_snek = { 0, .25 }
                player_start = true
                } 
            } else if rl.IsKeyDown(.LEFT) {
                if move_snek == { .25, 0 } {
                    // do nothing.
                } else {
                    move_snek = { -.25, 0 }
                    player_start = true
                }
            } else if rl.IsKeyDown(.RIGHT) {
                if move_snek == { -.25, 0 } {
                    // do nothing.
                } else {
                    move_snek = { .25, 0 }
                    player_start = true
                }
            }
            tick_timer = TICK_RATE + tick_timer
            snek_head_pos += move_snek
        }

            head_rect = rl.Rectangle {
                f32(snek_head_pos.x*CELL_SIZE),
                f32(snek_head_pos.y*CELL_SIZE),
                CELL_SIZE, CELL_SIZE
            }
    

        rl.BeginDrawing()
        rl.ClearBackground({ 0, 128, 200, 255 })
        rl.BeginMode2D(camera)

        rl.DrawRectangleRec(head_rect, { 190, 80, 0, 255 })

        rl.EndMode2D()
        rl.EndDrawing()
    }
    rl.CloseWindow()
}

init_game_state :: proc() {
    snek_head_pos = { GRID_SIZE /2, GRID_SIZE /2 }
    move_snek = { 0, 0 }
    player_start = false
}