package snek

import rl "vendor:raylib"
import "core:math"
import "core:fmt"

WINDOW_SIZE :: 1000
GRID_WIDTH :: 20
CELL_SIZE :: 16
TICK_RATE :: 0.123
CANVAS_SIZE :: GRID_WIDTH*CELL_SIZE
MAX_SNEK_LENGTH :: GRID_WIDTH*GRID_WIDTH

Vec2i :: [2] int
tick_timer: f32 = TICK_RATE
snek: [MAX_SNEK_LENGTH] Vec2i
snek_length: int
game_over: bool
move_snek: Vec2i
food_pos: Vec2i

game_start :: proc() {
    snek_length = 3
    move_snek = {0, 1}
    snek[0] = { GRID_WIDTH / 2, GRID_WIDTH / 2 }
    snek[1] = snek[0] - { 0, 1 }
    snek[2] = snek[0] - { 0, 2 }
    game_over = false
    place_food()
}

place_food :: proc() {
    occupied: [GRID_WIDTH][GRID_WIDTH] bool

    for i in 0..<snek_length {
        occupied[snek[i].x][snek[i].y] = true
    }

    free_cells := make([dynamic]Vec2i, context.temp_allocator)

    for x in 0..<GRID_WIDTH {
        for y in 0..<GRID_WIDTH {
            if !occupied[x][y] {
                append(&free_cells, Vec2i {x, y})
            }
        }
    }

    if len(free_cells) > 0 {
        rand_cell_index :i32= rl.GetRandomValue(0, i32(len(free_cells)-1))
        food_pos = free_cells[rand_cell_index]
    }
}

main :: proc() {

    rl.SetConfigFlags({.VSYNC_HINT})
    rl.InitWindow(WINDOW_SIZE, WINDOW_SIZE, "sNeK Game")
    rl.InitAudioDevice()

    game_start()
    
    food_sprite := rl.LoadTexture("img/food.png")
    head_sprite := rl.LoadTexture("img/head.png")
    body_sprite := rl.LoadTexture("img/body.png")
    tail_sprite := rl.LoadTexture("img/tail.png")

    eat_sound := rl.LoadSound("sounds/eat.wav")
    crash_sound := rl.LoadSound("sounds/crash.wav")

    next_pos, cur_pos: Vec2i
    camera := rl.Camera2D {
        zoom = f32(WINDOW_SIZE) / CANVAS_SIZE
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
            if move_snek == { 1, 0 } {

            } else {
                move_snek = { -1, 0 }
            }

        } else if rl.IsKeyDown(.RIGHT) {
            if move_snek == { -1, 0 } {

            } else {
                move_snek = { 1, 0 }
            }
        }

        if game_over {
            if rl.IsKeyPressed(.ENTER) {
                game_start()
            }
        } else {
           tick_timer -= rl.GetFrameTime()
        }
        
        if tick_timer <= 0 {
            next_pos = snek[0]
            snek[0] += move_snek

            if snek[0].x < 0 || snek[0].y < 0 || snek[0].x >= GRID_WIDTH || snek[0].y >= GRID_WIDTH {
                game_over = true
                rl.PlaySound(crash_sound)
            }

            for i in 1..<snek_length {
                cur_pos = snek[i]

                if cur_pos == snek[0] {
                    game_over = true
                    rl.PlaySound(crash_sound)
                }
                snek[i] = next_pos
                next_pos = cur_pos
            }

            if snek[0] == food_pos {
                snek[snek_length] = next_pos
                snek_length += 1
                rl.PlaySound(eat_sound)
                place_food()
            }
            tick_timer = TICK_RATE + tick_timer
        }

        rl.BeginDrawing()
        rl.ClearBackground({1, 1, 1, 255})
        rl.BeginMode2D(camera)

        rl.DrawTextureV(food_sprite, {f32(food_pos.x*CELL_SIZE), f32(food_pos.y*CELL_SIZE)}, rl.WHITE)

        for i in 0..<snek_length {
            tmp_sprite := body_sprite
            dir: Vec2i

            if i == 0 {
                tmp_sprite = head_sprite
                dir = snek[0] - snek[i+1]

            } else if i == snek_length-1 {
                tmp_sprite = tail_sprite
                dir = snek[i-1] - snek[i]
            } else {
                dir = snek[i-1] - snek[i]
            }

            rot := math.atan2(f32(dir.y), f32(dir.x)) * math.DEG_PER_RAD

            src := rl.Rectangle {
                0, 0,
                f32(tmp_sprite.width),
                f32(tmp_sprite.height) 
            }
            if rl.GetFrameTime() > 0 {
                if i == 0 {
                    if move_snek == { -1, 0 } {
                       src = rl.Rectangle {
                            0, 0,
                            f32(tmp_sprite.width),
                            f32(tmp_sprite.height)* -1.0 
                        } 
                    }
                }  

            dest := rl.Rectangle {
                f32(snek[i].x)*CELL_SIZE + 0.5*CELL_SIZE,
                f32(snek[i].y)*CELL_SIZE + 0.5*CELL_SIZE,
                CELL_SIZE,
                CELL_SIZE
            }

            rl.DrawTexturePro(tmp_sprite, src, dest, {CELL_SIZE, CELL_SIZE}*0.5, rot, rl.WHITE)
            }
        }
        

        if game_over {
            rl.DrawText("Game Over", 98, 4, 25, rl.RED)
            rl.DrawText("Press Enter to try again.", 70, 30, 15, rl.GRAY)
        }

        score := snek_length-3
        score_str := fmt.ctprintf("Score: %v", score)
        rl.DrawText(score_str, 4, 299, 15, rl.GRAY)

        rl.EndDrawing()
        rl.EndMode2D()
        free_all(context.temp_allocator)
    }

    rl.UnloadTexture(food_sprite)
    rl.UnloadTexture(head_sprite)
    rl.UnloadTexture(body_sprite)
    rl.UnloadTexture(tail_sprite)
    rl.UnloadSound(eat_sound)
    rl.UnloadSound(crash_sound)
    rl.CloseAudioDevice()
    rl.CloseWindow()
}