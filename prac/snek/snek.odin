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
Up :: Vec2 { 0, -1 }
Down :: Vec2 { 0, 1 }
Left :: Vec2 { -1, 0 }
Right :: Vec2 { 1, 0 }
move_snek: Vec2
snek_leng: int
food_pos: Vec2
snek: [SNEK_MAX_LENG] Vec2
tick_timer: f32 = TICK_RATE
game_over: bool
cur_dir: Vec2
prev_dir: Vec2
main :: proc() {
    rl.InitWindow(WINDOW_SIZE, WINDOW_SIZE, "Snek Game")
    rl.SetConfigFlags({.VSYNC_HINT})
    camera := rl.Camera2D {
        zoom = f32(WINDOW_SIZE)/CANVAS_SIZE
    }
    food_sprite := rl.LoadTexture("textures/apple.png")
    head_sprite := rl.LoadTexture("textures/head.png")
    body_sprite := rl.LoadTexture("textures/body.png")
    tail_sprite := rl.LoadTexture("textures/tail.png")
    corner_sprite := rl.LoadTexture("textures/corner.png")
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
            if snek[0] == food_pos {
                place_food()
                snek_leng += 1
            }
            if snek[0].x >= GRID_WIDTH || snek[0].x < 0 ||
                snek[0].y >= GRID_WIDTH || snek[0].y < 0 {
                    game_over = true
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
                rl.DrawText("Game Over", 350, 40, 60, rl.RED)
                rl.DrawText("Press ENTER to play again", 360, 100, 20, rl.GRAY)
                if rl.IsKeyPressed(.ENTER) {
                    game_state()
                }
            } else {
                tick_timer = TICK_RATE + tick_timer
            }
        }
        rl.BeginDrawing()
        rl.ClearBackground(rl.BLACK)
        rl.BeginMode2D(camera)
        rl.DrawTextureV(food_sprite, {f32(food_pos.x), f32(food_pos.y)} * CELL_SIZE, rl.WHITE)
        for i in 0..<snek_leng {
            part_sprite := body_sprite
            source := rl.Rectangle {
                0, 0,
                f32(part_sprite.width),
                f32(part_sprite.height)
            }
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
                    part_sprite = corner_sprite
                    if cur_dir == Left && prev_dir == Down ||
                        cur_dir == Up && prev_dir == Left ||
                        cur_dir == Right && prev_dir == Up ||
                        cur_dir == Down && prev_dir == Right {
                            source = rl.Rectangle {
                                0, 0,
                                f32(part_sprite.width),
                                -f32(part_sprite.height)
                            }
                        }
                }
            }
            rot := math.atan2(f32(cur_dir.y), f32(cur_dir.x)) * math.DEG_PER_RAD
            dest := rl.Rectangle {
                f32(snek[i].x) * CELL_SIZE + 0.5 * CELL_SIZE,
                f32(snek[i].y) * CELL_SIZE + 0.5 * CELL_SIZE,
                CELL_SIZE, CELL_SIZE
            }
            rl.DrawTexturePro(part_sprite, source, dest, { CELL_SIZE, CELL_SIZE } * 0.5, rot, rl.WHITE)
        }
        score := snek_leng-3
        score_str := fmt.ctprintf("Score: %v", score)
        rl.DrawText(score_str, 2, 310, 12, rl.YELLOW)
        free_all(context.temp_allocator)
        rl.EndMode2D()
        rl.EndDrawing()
    }
    rl.UnloadTexture(food_sprite)
    rl.UnloadTexture(head_sprite)
    rl.UnloadTexture(body_sprite)
    rl.UnloadTexture(tail_sprite)
    rl.UnloadTexture(corner_sprite)
    rl.CloseWindow()
}
game_state :: proc() {
    snek = {}
    move_snek = { 0, 1 }
    snek[0] = { GRID_WIDTH /2, GRID_WIDTH /2 }
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
    free_cells := make([dynamic] Vec2, context.temp_allocator)
    for x in 0..<GRID_WIDTH {
        for y in 0..<GRID_WIDTH {
            if !occupied[x][y] {
                append(&free_cells, Vec2 {x,y})
            }
        }
    }
    rand := rl.GetRandomValue(0, i32(len(free_cells))-1)
    food_pos = free_cells[rand]
}