package hangman
import "core:bytes"
import "core:fmt"
import "core:math/rand"
import "core:mem"
import "core:os"
import "core:strings"
import rl "vendor:raylib"

Vec2 :: rl.Vector2
BACKGROUND_COLOR :: rl.Color{15, 30, 175, 255}
ORANGE_CLR :: rl.Color{210, 100, 75, 255}
WINDOW_SIZE :: 920
GRID_WIDTH :: 20
CELL_SIZE :: 16
CANVAS_SIZE :: GRID_WIDTH * CELL_SIZE
DIVIDE_FRAMES_BY :: 20
BANK_SIZE :: 24 // Update if any words are added/removed from word_list.txt
MAX_INPUT :: 1

guess: u8
lives: int
score: f64
debug: bool
correct: int
ans_leng: int
answer: string
valid_guess: bool
letter_count: i32
ans_board: []byte
game_state: STATE
game_started: bool
mouse_on_text: bool
frames_counter: int
contains_space: bool
seen_runes: ^map[u8]bool
ans_board_space_indx: int
guess_buff: [MAX_INPUT]byte
word_bank: [BANK_SIZE]string
text_box := rl.Rectangle {
    8 * CELL_SIZE + CELL_SIZE * 0.5,
    14 * CELL_SIZE,
    CELL_SIZE - 4,
    CELL_SIZE - 4,
}

STATE :: enum {
    Welcome,
    Playing,
    Lost,
    Won,
}

main :: proc() {

    when ODIN_DEBUG {
        track1: mem.Tracking_Allocator
        track2: mem.Tracking_Allocator
        mem.tracking_allocator_init(&track1, context.allocator)
        mem.tracking_allocator_init(&track2, context.temp_allocator)
        context.allocator = mem.tracking_allocator(&track1)
        context.temp_allocator = mem.tracking_allocator(&track2)
        defer {
            if len(track1.allocation_map) > 0 {
                for _, entry in track1.allocation_map {
                    fmt.eprintf("%v leaked %v bytes\n", entry.location, entry.size)
                }
            }
            if len(track2.allocation_map) > 0 {
                for _, entry in track2.allocation_map {
                    fmt.eprintf("%v leaked %v bytes\n", entry.location, entry.size)
                }
            }
            mem.tracking_allocator_destroy(&track1)
            mem.tracking_allocator_destroy(&track2)
        }
    }

    // answer will be 'aaaaaaa' if launched with the argument 'test' or 'debug'
    if len(os.args) > 1 {
        arguments := os.args[1:]
        if arguments[0] == "test" || arguments[0] == "debug" {
            debug = true
        }
    }

    // Read word_list into word_bank[]
    word_list_buf, ok := os.read_entire_file("word_list.txt", context.allocator)
    checkErr(ok)
    indx: int
    word_list_str := string(word_list_buf)
    for str in strings.split_iterator(&word_list_str, ",") {
        word_bank[indx] = strings.clone(str, context.allocator)
        indx += 1
    }
    delete(word_list_buf)

    // Create map for guessed letters
    map_temp := make(map[u8]bool, context.allocator)
    seen_runes = &map_temp
    game_init()

    camera := rl.Camera2D {
        zoom = f32(WINDOW_SIZE) / CANVAS_SIZE,
    }
    rl.SetConfigFlags({.VSYNC_HINT})
    rl.InitWindow(WINDOW_SIZE, WINDOW_SIZE, "Hangman")
    rl.SetTargetFPS(60)
    ////////////////////// Start Main Loop ///////////////////////////
    for !rl.WindowShouldClose() {

        rl.BeginDrawing()
        rl.ClearBackground(BACKGROUND_COLOR)
        rl.BeginMode2D(camera)

        // Check if player won or lost
        if lives < 1 {
            game_state = .Lost
            score = 0
        } else if correct >= ans_leng && game_state == .Playing {
            score = score * (f64(lives) / 0.5)
            game_state = .Won
        }

        switch game_state {

            case .Welcome:
                rl.DrawText("Welcome to Hangman!", 38, 175, 25, ORANGE_CLR)
                rl.DrawText("Press SPACE to begin.", 96, 200, 9, ORANGE_CLR)
                if rl.IsKeyPressed(.SPACE) || rl.IsKeyPressed(.ENTER) {
                    game_state = .Playing
                    game_started = true
                }

            case .Playing:
                draw_game_board()
                handle_input()

            case .Won:
                draw_game_board()
                rl.DrawText("Congratulations!\n      You Won!", 38, 170, 25, ORANGE_CLR)
                tmp := strings.clone_to_cstring(string(ans_board), context.temp_allocator)
                rl.DrawText(tmp, i32(text_box.x - 25), i32(text_box.y) + 15, 13, rl.BLACK)
                if rl.IsKeyPressed(.ENTER) {
                    game_init()
                }

            case .Lost:
                draw_game_board()
                rl.DrawText("Game Over.", 80, 175, 20, rl.MAROON)
                rl.DrawText("Press ENTER to play again.", 20, 195, 20, rl.MAROON)
                ans_str := fmt.ctprintf("Answer was %s", answer)
                rl.DrawText(ans_str, 6 * CELL_SIZE, 14 * CELL_SIZE, 10, rl.RED)
                if rl.IsKeyPressed(.ENTER) {
                    game_init()
                }
        }

        free_all(context.temp_allocator)
        rl.EndMode2D()
        rl.EndDrawing()
        ///////////////////////// End of Main Loop /////////////////////////
    }
    rl.CloseWindow()
    delete(map_temp)
    delete(ans_board)
    for s in word_bank {
        delete(s)
    }
}

checkErr :: proc(ok: bool) {
    if !ok {
        panic("Error.")
    }
}

random_num :: proc(min: int, max: int) -> i32 {
    min := i32(min)
    max := i32(max)
    seed := rand.uint32()
    rl.SetRandomSeed(seed)
    return rl.GetRandomValue(min, max)
}

game_init :: proc() {

    if game_started {
        delete(ans_board, context.allocator)
        clear_map(seen_runes)
        game_state = .Playing
    } else {
        game_state = .Welcome
    }

    key := random_num(0, BANK_SIZE - 2)
    if debug {
        key = BANK_SIZE - 1
    }

    lives = 6
    correct = 0
    letter_count = 0
    guess_buff[0] = 0
    valid_guess = false
    answer = word_bank[key]
    answer = strings.trim_right_space(answer)
    ans_leng = len(answer)
    ans_board_leng := ans_leng + ans_leng - 1

    // Below creates the 'ans_board' based off a random word from word_bank[].
    // 'ans_board' is formatted like '_ _ _ _' where '_' is a
    // blank space for each letter in 'answer'.
    ans_board = make([]byte, ans_board_leng, context.allocator)
    contains_space = strings.contains_space(answer)
    if contains_space {
        space_indx := strings.index_rune(answer, ' ')
        ans_leng -= 1
        ans_board_space_indx = (space_indx * 2) - 1
    }
    for i: int; i < ans_board_leng; i += 2 {
        if contains_space && i - 1 == ans_board_space_indx {
            ans_board[i] = ' '
            i -= 1
            continue
        }
        // Using underscore for a blank space.
        ans_board[i] = '_'
        // Adding a space between `_`'s
        if i != ans_board_leng - 1 {
            ans_board[i + 1] = ' '
        }
    }
}

draw_game_board :: proc() {

    rect := rl.Rectangle{9 * CELL_SIZE, 2 * CELL_SIZE + 8, CELL_SIZE / 4, CELL_SIZE + 5}
    rl.DrawRectangleRec(rect, rl.BROWN) // draw rope

    pos := Vec2{5, GRID_WIDTH / 2}
    rect = rl.Rectangle{pos.x * CELL_SIZE, pos.y * CELL_SIZE, CELL_SIZE * 6, CELL_SIZE / 2}
    rl.DrawRectangleRec(rect, ORANGE_CLR) // Draw base.

    pos += {0, -7} // Move y position up 7.
    rect = rl.Rectangle {
        pos.x * CELL_SIZE + CELL_SIZE / 2,
        pos.y * CELL_SIZE,
        CELL_SIZE / 2,
        CELL_SIZE * 7,
    }
    rl.DrawRectangleRec(rect, ORANGE_CLR) // Draw vertical pole.

    pos += {0, -1} // Move y position up 1.
    rect = rl.Rectangle {
        pos.x * CELL_SIZE + CELL_SIZE / 2,
        pos.y * CELL_SIZE + CELL_SIZE / 2,
        CELL_SIZE * 4,
        CELL_SIZE / 2,
    }
    rl.DrawRectangleRec(rect, ORANGE_CLR) // Draw top brace.

    draw_game_text()

    #partial switch game_state {
        case .Playing:
            draw_man()
            score_str := fmt.ctprintf("Score: %v", score)
            rl.DrawText(score_str, 7 * CELL_SIZE, 16 * CELL_SIZE, 15, rl.BLACK)
        case .Won:
            draw_man_lives()
            score_str := fmt.ctprintf("Score: %v", score)
            rl.DrawText(score_str, 7 * CELL_SIZE, 16 * CELL_SIZE, 15, rl.BLACK)
        case .Lost:
            draw_man()
    }

}

draw_man :: proc() {

    if lives < 6 {

        rl.DrawCircleLines(9 * CELL_SIZE + 2, 5 * CELL_SIZE - 10, 10, rl.LIGHTGRAY)
        rl.DrawCircleLines(9 * CELL_SIZE + 2, 5 * CELL_SIZE - 10, 9.75, rl.LIGHTGRAY)
        rl.DrawCircleLines(9 * CELL_SIZE + 2, 5 * CELL_SIZE - 10, 9.5, rl.LIGHTGRAY) // Draw Head
        rl.DrawCircleLines(9 * CELL_SIZE + 2, 5 * CELL_SIZE - 10, 9.25, rl.LIGHTGRAY)
        rl.DrawCircleLines(9 * CELL_SIZE + 2, 5 * CELL_SIZE - 10, 9, rl.LIGHTGRAY)
        pos := Vec2{9 * CELL_SIZE, 2 * CELL_SIZE + 8}

        if lives < 5 {
            rect := rl.Rectangle{pos.x - 1, pos.y + 39, CELL_SIZE / 2 - 2, CELL_SIZE + 15}
            rl.DrawRectangleRec(rect, rl.LIGHTGRAY) // Draw Body

            if lives < 4 {
                arm_rect := rect
                arm_rect.x += -0.5
                arm_rect.y += 4
                arm_rect.width -= 1
                arm_rect.height -= 8
                r_leg_rect := arm_rect
                rl.DrawRectanglePro(arm_rect, {0, 0}, 45, rl.LIGHTGRAY) // Draw Right Arm

                if lives < 3 {
                    arm_rect.x += 3
                    arm_rect.y += 3.5
                    l_leg_rect := arm_rect
                    rl.DrawRectanglePro(arm_rect, {0, 0}, -45, rl.LIGHTGRAY) // Draw Left Arm

                    if lives < 2 {
                        r_leg_rect.x += 1
                        r_leg_rect.y += 22
                        rl.DrawRectanglePro(r_leg_rect, {0, 0}, 45, rl.LIGHTGRAY) //Draw Right Leg

                        if lives < 1 {
                            l_leg_rect.y += 22
                            rl.DrawRectanglePro(l_leg_rect, {0, 0}, -45, rl.LIGHTGRAY) // Draw Left Leg
                        }
                    }
                }
            }
        }
    }
}

draw_man_lives :: proc() {

    rl.DrawCircleLines(9 * CELL_SIZE + 2, 7 * CELL_SIZE - 7, 10, rl.LIGHTGRAY)
    rl.DrawCircleLines(9 * CELL_SIZE + 2, 7 * CELL_SIZE - 7, 9.75, rl.LIGHTGRAY)
    rl.DrawCircleLines(9 * CELL_SIZE + 2, 7 * CELL_SIZE - 7, 9.5, rl.LIGHTGRAY) // Draw Head
    rl.DrawCircleLines(9 * CELL_SIZE + 2, 7 * CELL_SIZE - 7, 9.25, rl.LIGHTGRAY)
    rl.DrawCircleLines(9 * CELL_SIZE + 2, 7 * CELL_SIZE - 7, 9, rl.LIGHTGRAY)

    pos := Vec2{9 * CELL_SIZE, 5 * CELL_SIZE - 4}
    rect := rl.Rectangle{pos.x - 1, pos.y + 39, CELL_SIZE / 2 - 2, CELL_SIZE + 15}
    rl.DrawRectangleRec(rect, rl.LIGHTGRAY) // Draw Body

    arm_rect := rect
    arm_rect.x -= 1
    arm_rect.y += 4
    arm_rect.width -= 1
    arm_rect.height -= 8
    r_leg_rect := arm_rect
    arm_rect.x += 4
    rl.DrawRectanglePro(arm_rect, {0, 0}, 135, rl.LIGHTGRAY) // Draw Right Arm

    arm_rect.x += 3.5
    arm_rect.y += 3.5
    l_leg_rect := arm_rect
    l_leg_rect.x -= 4
    rl.DrawRectanglePro(arm_rect, {0, 0}, -135, rl.LIGHTGRAY) // Draw Left Arm

    r_leg_rect.x += 1
    r_leg_rect.y += 22
    rl.DrawRectanglePro(r_leg_rect, {0, 0}, 45, rl.LIGHTGRAY) //Draw Right Leg

    l_leg_rect.y += 22
    rl.DrawRectanglePro(l_leg_rect, {0, 0}, -45, rl.LIGHTGRAY) // Draw Left Leg
}

draw_game_text :: proc() {

    if game_state != .Lost {

        mouse_pos := rl.GetMousePosition()
        if rl.CheckCollisionPointRec({mouse_pos.x / 2.865, mouse_pos.y / 2.865}, text_box) {
            rl.SetMouseCursor(.IBEAM)
        } else {
            rl.SetMouseCursor(.DEFAULT)
        }
        rl.DrawRectangleRec(text_box, rl.LIGHTGRAY)
        rl.DrawRectangleLines(
            i32(text_box.x),
            i32(text_box.y),
            i32(text_box.width),
            i32(text_box.height),
            rl.RED,
        )
    }

    rl.DrawRectangleLinesEx(
        {13 * CELL_SIZE, 4 * CELL_SIZE - 4, 83, 1},
        1,
        {210, 100, 75, 255},
    )
    rl.DrawText(
        rl.TextFormat("Correct/Total\n       %i/%i", correct, ans_leng),
        13 * CELL_SIZE + 3,
        3 * CELL_SIZE + 2,
        10,
        rl.GRAY,
    )

    if lives > 3 {
        lives_str := fmt.ctprintf("Lives: %i", lives)
        rl.DrawText(lives_str, CELL_SIZE, 3 * CELL_SIZE + 2, 10, rl.GRAY)
    } else {
        lives_str := fmt.ctprintf("Lives: %i", lives)
        rl.DrawText(lives_str, CELL_SIZE, 3 * CELL_SIZE + 2, 10, rl.MAROON)
    }

    if game_state == .Playing {

        ans_board_cstr := strings.clone_to_cstring(string(ans_board), context.temp_allocator)
        rl.DrawText(ans_board_cstr, i32(text_box.x - 25), i32(text_box.y) - 35, 10, rl.BLACK)

        if letter_count < MAX_INPUT {

            if (frames_counter / DIVIDE_FRAMES_BY) % 2 == 0 {
                // Removed rl.MeasureText since we are only using
                // one character at a time, so it was unneeded.
                rl.DrawText("_", i32(text_box.x) + 2, i32(text_box.y) + 3, 9, rl.MAROON)
            }
            rl.DrawText(
                "Guess a letter.",
                i32(text_box.x) - 32,
                i32(text_box.y) + 13,
                10,
                rl.GRAY,
            )
        } else {

            c_guess := strings.clone_to_cstring(string(guess_buff[:]), context.temp_allocator)
            rl.DrawText(c_guess, i32(text_box.x) + 3, i32(text_box.y) + 1, 9, rl.MAROON)
            if valid_guess {
                if seen_runes[guess] {
                    rl.DrawText(
                        "Already been guessed.",
                        i32(text_box.x) - 38,
                        i32(text_box.y) + 13,
                        10,
                        rl.MAROON,
                    )
                    rl.DrawText(
                        "Press ENTER to try again.",
                        i32(text_box.x) - 38,
                        i32(text_box.y) + 24,
                        10,
                        rl.MAROON,
                    )
                } else {
                    rl.DrawText(
                        "Press Enter to confirm,",
                        i32(text_box.x) - 38,
                        i32(text_box.y) + 13,
                        10,
                        rl.GRAY,
                    )
                    rl.DrawText(
                        "or BACKSPACE to delete.",
                        i32(text_box.x) - 38,
                        i32(text_box.y) + 24,
                        10,
                        rl.GRAY,
                    )
                }
            } else {
                rl.DrawText(
                    "Not a valid guess.",
                    i32(text_box.x) - 38,
                    i32(text_box.y) + 13,
                    10,
                    rl.MAROON,
                )
                rl.DrawText(
                    "Press ENTER to try again...",
                    i32(text_box.x) - 38,
                    i32(text_box.y) + 24,
                    10,
                    rl.MAROON,
                )
            }
            if frames_counter > 100000 {
                frames_counter = 0
            }
        }
    }
}

handle_input :: proc() {
    r := rl.GetCharPressed()
    for r > 0 {
        if r >= 33 && r <= 126 && letter_count < MAX_INPUT {
            guess_buff[letter_count] = u8(r)
            letter_count += 1
        }
        r = rl.GetCharPressed()
    }
    if rl.IsKeyPressed(.BACKSPACE) {
        letter_count -= 1

        if letter_count < 0 {
            letter_count = 0
        }
        guess_buff[letter_count] = 0
    }
    frames_counter += 1

    if letter_count > 0 {
        check_guess()
    }
}

check_guess :: proc() {

    if guess_buff[0] >= 'A' && guess_buff[0] <= 'Z' {
        valid_guess = true
        guess = guess_buff[0] + 32

    } else if guess_buff[0] >= 'a' && guess_buff[0] <= 'z' {
        valid_guess = true
        guess = guess_buff[0]

    } else {
        valid_guess = false
    }

    if valid_guess {
        if rl.IsKeyPressed(.ENTER) || rl.IsKeyPressed(.SPACE) {
            if !seen_runes[guess] {
                seen_runes[guess] = true
                tmp := rune(guess)

                if strings.contains_rune(answer, tmp) {
                    score += (f64(ans_leng) / 0.5)
                    place_found_rune(tmp)
                } else {
                    lives -= 1
                }
            }
            guess_buff[0] = 0
            letter_count = 0
        }
    } else {
        if rl.IsKeyPressed(.ENTER) || rl.IsKeyPressed(.SPACE) {
            guess_buff[0] = 0
            letter_count = 0
        }
    }
}

place_found_rune :: proc(find: rune) {

    indx: int
    for r in answer {
        if r == find {
            if contains_space {
                if (indx * 2) - 1 >= ans_board_space_indx {
                    ans_board[(indx * 2) - 1] = byte(r) // place letters after the space
                } else {
                    ans_board[indx * 2] = byte(r) // place letters before the space
                }
            } else {
                ans_board[indx * 2] = byte(r) // words with no space
            }
            correct += 1
        }
        indx += 1
    }
}
