package snek

import rl "vendor:raylib"
import "core:math"
import "core:fmt"

WINDOW_SIZE :: 920
GRID_WIDTH :: 20
CELL_SIZE :: 16
CANVAS_SIZE :: GRID_WIDTH*CELL_SIZE
TICK_RATE :: 0.13
MAX_SNEK_LENGTH :: GRID_WIDTH*GRID_WIDTH

Vec2 :: rl.Vector2
Up :: Vec2 { 0, -1 }
Down :: Vec2 { 0, 1 }
Left :: Vec2 { -1, 0 }
Right :: Vec2 { 1, 0 }
move_snek: Vec2
food_pos: Vec2
snek_leng: int
game_over: bool
cur_dir: Vec2
prev_dir: Vec2
tick_timer: f32 = TICK_RATE
snek: [MAX_SNEK_LENGTH] Vec2

main :: proc() {
    rl.InitWindow(WINDOW_SIZE, WINDOW_SIZE, "snek")
    rl.SetConfigFlags({.VSYNC_HINT})
    camera := rl.Camera2D {
        zoom = f32(WINDOW_SIZE)/CANVAS_SIZE
    }
    food_sprite := rl.LoadTexture("textures/apple.png")
    head_sprite := rl.LoadTexture("textures/head.png")
    body_sprite := rl.LoadTexture("textures/body.png")
    tail_sprite := rl.LoadTexture("textures/tail.png")
    bend_sprite := rl.LoadTexture("textures/bend.png")
    
    game_state()

    for !rl.WindowShouldClose() {
        if rl.IsKeyDown(.UP) {
            if move_snek != Down {
                move_snek = Up
            }
        } else if rl.IsKeyDown(.DOWN) {
            if move_snek != Up {
                move_snek = Down
            }
        } else if rl.IsKeyDown(.LEFT) {
            if move_snek != Right {
                move_snek = Left
            }
        } else if rl.IsKeyDown(.RIGHT) {
            if move_snek != Left {
                move_snek = Right
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
                if snek[0] == cur_pos {
                    game_over = true
                }
            }
            if game_over {
                rl.DrawText("Game Over", 300, 100, 50, rl.RED)
                if rl.IsKeyPressed(.ENTER) {
                    game_state()
                }
            } else {
                tick_timer = TICK_RATE + tick_timer
            }
        }

        rl.BeginDrawing()
            rl.BeginMode2D(camera)
            rl.ClearBackground(rl.BLACK)

            part_sprite := body_sprite
            src := rl.Rectangle {
                0, 0,
                f32(part_sprite.width),
                f32(part_sprite.height)
            }
            for i in 0..<snek_leng {
                if i == 0 {

                    part_sprite = head_sprite
                    cur_dir = snek[i] - snek[i+1]

                } else if i == snek_leng-1 {

                    part_sprite = tail_sprite
                    cur_dir = snek[i-1] - snek[i]

                } else {

                    cur_dir = snek[i-1] - snek[i]
                    prev_dir = snek[i] - snek[i+1]

                    if cur_dir != prev_dir {

                        part_sprite = bend_sprite
                        
                        if cur_dir == Left && prev_dir == Down ||
                            cur_dir == Up && prev_dir == Left ||
                            cur_dir == Right && prev_dir == Up ||
                            cur_dir == Down && prev_dir == Right {

                            src = rl.Rectangle {
                                0, 0,
                                f32(part_sprite.width),
                                -f32(part_sprite.height)
                            }   
                        }
                    }
                }
                rot := math.atan2(f32(cur_dir.y), f32(cur_dir.x)) * math.DEG_PER_RAD
                dest := rl.Rectangle {
                    snek[i].x * CELL_SIZE,
                    snek[i].y * CELL_SIZE,
                    CELL_SIZE, CELL_SIZE
                }
                rl.DrawTexturePro(part_sprite, src, dest, { CELL_SIZE, CELL_SIZE } * 0.5, rot, rl.WHITE)
            }

            rl.EndMode2D()
        rl.EndDrawing()
    }
    rl.CloseWindow()
}
game_state :: proc() {
    move_snek = { 0, 1 }
    snek = {}
    snek[0] = {GRID_WIDTH /2, GRID_WIDTH /2}
    snek[1] = snek[0] - { 0, 1 }
    snek[2] = snek[0] - { 0, 2 }
    snek_leng = 3
    game_over = false
    tick_timer = TICK_RATE
}