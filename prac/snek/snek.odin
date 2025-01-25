package snek

import rl "vendor:raylib"
import "core:math"
import "core:fmt"

WINDOW_SIZE :: 920
GRID_WIDTH :: 20
CELL_SIZE :: 16
MAX_SNEK_LENG :: GRID_WIDTH*GRID_WIDTH
CANVAS_SIZE :: GRID_WIDTH*CELL_SIZE
TICK_RATE :: 0.125

Vec2i :: [2] int

snek_leng: int
move_snek: Vec2i
prev_move: Vec2i
prev3rd_move: Vec2i
dir: Vec2i
food_pos: Vec2i
game_over: bool
tick_timer: f32 = TICK_RATE
snek: [MAX_SNEK_LENG] Vec2i

main :: proc () {
    rot : f32
    rl.InitWindow(WINDOW_SIZE, WINDOW_SIZE, "SNEK")
    rl.SetConfigFlags({.VSYNC_HINT})

    camera := rl.Camera2D {
        zoom = f32(WINDOW_SIZE) / CANVAS_SIZE
    }

    food_sprite := rl.LoadTexture("apple.png")
    head_sprite := rl.LoadTexture("head.png")
    body_sprite := rl.LoadTexture("body.png")
    tail_sprite := rl.LoadTexture("tail.png")
    corner_sprite := rl.LoadTexture("corner.png")

    game_state()

    for !rl.WindowShouldClose() {

        if rl.IsKeyDown(.UP) {
            if move_snek == { 0, 1 } {

            } else {
                move_snek = { 0, -1}
            }
        }
        if rl.IsKeyDown(.DOWN) {
            if move_snek == { 0, -1 } {

            } else {
                move_snek = { 0, 1}
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
        if rl.IsKeyDown(.SPACE) {
            if rl.IsKeyPressed(.SPACE) {
                
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
                rl.DrawText("Game Over", 250, 150, 80, rl.RED)
                rl.DrawText("Press Enter to play again.", 300, 220, 20, {150, 150, 150, 255})
                if rl.IsKeyPressed(.ENTER) {
                    game_state()
                }
            } else {
               tick_timer = TICK_RATE + tick_timer 
            }
            fmt.println(rot)
        }

        rl.ClearBackground(rl.BLACK)
        rl.BeginDrawing()
        rl.BeginMode2D(camera)
        
        rl.DrawTextureV(food_sprite, {f32(food_pos.x), f32(food_pos.y)}*CELL_SIZE , rl.WHITE)
        
        for i in 0..<snek_leng {

            part_sprite := body_sprite
            if i == 0 {
                part_sprite = head_sprite
                dir = snek[i] - snek[i + 1]
            } else if i == snek_leng-1 {
                part_sprite = tail_sprite
                dir = snek[i-1] - snek[i]
            } else {
                next_dir := snek[i] - snek[i + 1]
                dir = snek[i - 1] - snek[i]
                if dir != next_dir {
                    part_sprite = corner_sprite
                }
            }
            
            rot = math.atan2(f32(dir.y), f32(dir.x)) * math.DEG_PER_RAD

            source := rl.Rectangle {
                0, 0,
                f32(part_sprite.width),
                f32(part_sprite.height)
            }
            dest := rl.Rectangle {
                f32(snek[i].x)*CELL_SIZE + 0.5 * CELL_SIZE,
                f32(snek[i].y)*CELL_SIZE + 0.5 * CELL_SIZE,
                CELL_SIZE, CELL_SIZE

            }

            rl.DrawTexturePro(part_sprite, source, dest, {CELL_SIZE, CELL_SIZE} * 0.5, rot, rl.WHITE)
            fmt.println(rot)
            //rl.DrawTextureEx(part_sprite, {f32(snek[i].x), f32(snek[i].y)}*CELL_SIZE, rot, 1, rl.RED)
        }
        
        
        free_all(context.temp_allocator)
        rl.EndDrawing()
        rl.EndMode2D()
    }

    rl.UnloadTexture(head_sprite)
    rl.CloseWindow()
}

game_state :: proc() {

    move_snek = { 0, 1 }
    snek = {}
    snek[0] = { GRID_WIDTH / 2, 5 }
    snek[1] = snek[0] - { 0, 1 }
    snek[2] = snek[0] - { 0, 2 }
    snek_leng = 3
    game_over = false
    tick_timer = TICK_RATE
    place_food()
}
place_food :: proc() {

    occupied: [GRID_WIDTH] [GRID_WIDTH] bool

    for i in 0..<snek_leng {
        occupied [snek[i].x] [snek[i].y] = true
    }
    
    free_cells := make([dynamic] Vec2i, context.temp_allocator)
    for x in 0..<GRID_WIDTH {
        for y in 0..<GRID_WIDTH {
            if !occupied[x][y] {
                append(&free_cells, Vec2i { x, y })
            }
        }
    }
    rand := rl.GetRandomValue(0, i32(len(free_cells)-1))
    food_pos = free_cells[rand]
}