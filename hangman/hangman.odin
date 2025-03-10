package hangman
import "core:os"
import "core:fmt"
import "core:mem"
import "core:bytes"
import "core:strings"
import "core:sys/info"
import "core:math/rand"
import rl "vendor:raylib"

Vec2 :: rl.Vector2
BACKGROUND_COLOR :: rl.Color { 15, 30, 175, 255 }
ORANGE_CLR :: rl.Color { 210, 100, 75, 255 }
WINDOW_SIZE :: 920
GRID_WIDTH :: 20
CELL_SIZE :: 16
CANVAS_SIZE :: GRID_WIDTH*CELL_SIZE
DIVIDE_FRAMES_BY :: 20
BANK_SIZE :: 24
MAX_INPUT :: 1

key: i32
guess: u8
leng: int
lives: int
score: f64
debug: bool
correct: int
answer: string
space_indx: int
game_start: bool
game_state: STATE
valid_guess: bool
ans_board: []byte
letter_count: i32
mouse_on_text: bool
frames_counter: int
contains_space: bool
guess_buff: [MAX_INPUT]byte
word_bank: [BANK_SIZE] string
seen_runes := make(map[u8]bool)
text_box := rl.Rectangle {
    8*CELL_SIZE+CELL_SIZE*0.5, 14*CELL_SIZE,
    CELL_SIZE-4, CELL_SIZE-4 
}
STATE :: enum {
    Welcome,
    Playing,
    Lost,
    Won,
}

main :: proc() {

    when ODIN_DEBUG {
		track: mem.Tracking_Allocator
		mem.tracking_allocator_init(&track, context.allocator)
		context.allocator = mem.tracking_allocator(&track)

		defer {

			if len(track.allocation_map) > 0 {
				for _, entry in track.allocation_map {
					fmt.eprintf("%v leaked %v bytes\n", entry.location, entry.size)
				}
			}

			if len(track.bad_free_array) > 0 {
				for entry in track.bad_free_array {
					fmt.eprintf("%v bad free at %v\n", entry.location, entry.memory)
				}
			}
			mem.tracking_allocator_destroy(&track)
		}
	}
    arguments:[]string
    if len(os.args) > 1 {
        arguments = os.args[1:]
        if arguments[0] == "test" ||
            arguments[0] == "debug" {
            debug = true
        }
    }
    buff, ok := os.read_entire_file("word_list.txt", context.allocator)
    if !ok {
        panic("Error. Unable to read file.")
    }
    indx: int
    input := string(buff)
    for str in strings.split_iterator(&input, ",") {
        word_bank[indx] = strings.clone(str, context.allocator)
        indx += 1
    }
    delete(buff)
    
    game_init()
    camera := rl.Camera2D {
        zoom = f32(WINDOW_SIZE)/CANVAS_SIZE
    }
    game_state = .Welcome
    rl.SetConfigFlags({.VSYNC_HINT})
    rl.InitWindow(WINDOW_SIZE, WINDOW_SIZE, "Hangman")
    rl.SetTargetFPS(60)
    
    ////////////////////// Start Main Loop ///////////////////////////
    for !rl.WindowShouldClose() {
        
        rl.BeginDrawing()
        rl.ClearBackground(BACKGROUND_COLOR)
        rl.BeginMode2D(camera)

        if lives < 1 {
            game_state = .Lost

        } else if correct >= leng {
            score += f64(leng)/0.5
            game_state = .Won
        }
        mouse_pos := rl.GetMousePosition()

        if rl.CheckCollisionPointRec({ mouse_pos.x/2.865, mouse_pos.y/2.865 }, text_box) {            
            mouse_on_text = true                                            
        } else {                                                            
            mouse_on_text = false                                           
        }

        if game_state == .Playing {
            if correct < leng {
                
                handle_input()
                check_input()
            }
        }

        if game_state == .Won {
            draw_man_lives()
            rl.DrawText("Congradulations!\n      You Won!", 38, 175, 25, ORANGE_CLR)
            tmp := strings.clone_from_bytes(ans_board, context.temp_allocator)
            ans_board_cstr := strings.clone_to_cstring(tmp, context.temp_allocator)
            rl.DrawText(ans_board_cstr, i32(text_box.x-25), i32(text_box.y)+15, 13, rl.BLACK)

            if rl.IsKeyPressed(.ENTER) {
                game_init()
            }
        }

        if game_state == .Welcome {
            rl.DrawText("Welcome to Hangman!", 38, 175, 25, ORANGE_CLR)
            rl.DrawText("Press SPACE to begin.", 96, 200, 9, ORANGE_CLR)

            if rl.IsKeyPressed(.SPACE) || rl.IsKeyPressed(.ENTER) {
                game_state = .Playing
                game_start = true
            }
        } else {
            draw_board()
        }

        if game_state == .Playing { 
            score_str := fmt.ctprintf("Score: %v", score)
            rl.DrawText(score_str, 7*CELL_SIZE, 16*CELL_SIZE, 15, rl.BLACK)

            if correct < leng {
                draw_text()
            }
        }

        if game_state == .Lost {
            rl.DrawText("        Game Over\nPress ENTER to play again.", 25, 175, 20, rl.MAROON)
            ans_str := fmt.ctprintf("Answer was %s", strings.to_pascal_case(answer, context.temp_allocator))
            rl.DrawText(ans_str, 6*CELL_SIZE, 14*CELL_SIZE, 10, rl.RED)

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
    delete_map(seen_runes)
    delete(ans_board)
    for s in word_bank {
        delete(s)
    }
}
draw_text :: proc() {
    
    rl.DrawRectangleRec(text_box, rl.LIGHTGRAY)
    rl.DrawRectangleLines(i32(text_box.x), i32(text_box.y), i32(text_box.width), i32(text_box.height), rl.RED)
    rl.DrawRectangleLinesEx({ 13*CELL_SIZE, 4*CELL_SIZE-4, 83, 1 }, 1, { 210, 100, 75, 255 })
        
    rl.DrawText(rl.TextFormat("Correct/Total\n       %i/%i", correct, len(answer)), 13*CELL_SIZE+3, 3*CELL_SIZE+2, 10, rl.GRAY)
    
    tmp := strings.clone_from_bytes(ans_board, context.temp_allocator)
    ans_board_cstr := strings.clone_to_cstring(tmp, context.temp_allocator)
    rl.DrawText(ans_board_cstr, i32(text_box.x-25), i32(text_box.y)-35, 10, rl.BLACK)

    if lives > 3 {
        lives_str := fmt.ctprintf("Lives: %i", lives)
        rl.DrawText(lives_str, CELL_SIZE, 3*CELL_SIZE+2, 10, rl.GRAY)
    } else {
        lives_str := fmt.ctprintf("Lives: %i", lives)
        rl.DrawText(lives_str, CELL_SIZE, 3*CELL_SIZE+2, 10, rl.MAROON)
    }
    
    tmp_str := string(guess_buff[:])
    c_guess := strings.clone_to_cstring(tmp_str, context.temp_allocator)

    if letter_count < MAX_INPUT {
        if (frames_counter/DIVIDE_FRAMES_BY)%2 == 0 {

            // Removed rl.MeasureText since we are only using 
            // one character at a time, so it was unneeded.
            rl.DrawText("_", i32(text_box.x) + 2, i32(text_box.y) + 3, 9, rl.MAROON)
        } 
        rl.DrawText("Guess a letter.", i32(text_box.x)-32, i32(text_box.y)+13, 10, rl.GRAY)
    } else {
        rl.DrawText(c_guess, i32(text_box.x)+3, i32(text_box.y)+1, 9, rl.MAROON)

        if valid_guess {
            if seen_runes[guess] {
                rl.DrawText("Already been guessed.", i32(text_box.x)-38, i32(text_box.y)+13, 10, rl.MAROON)
                rl.DrawText("Press ENTER to try again.", i32(text_box.x)-38, i32(text_box.y)+24, 10, rl.MAROON)
            } else {
                rl.DrawText("Press Enter to confirm,", i32(text_box.x)-38, i32(text_box.y)+13, 10, rl.GRAY)
                rl.DrawText("or BACKSPACE to delete.", i32(text_box.x)-38, i32(text_box.y)+24, 10, rl.GRAY)
            }
        } else {
            rl.DrawText("Not a valid guess.", i32(text_box.x)-38, i32(text_box.y)+13, 10, rl.MAROON)
            rl.DrawText("Press ENTER to try again...", i32(text_box.x)-38, i32(text_box.y)+24, 10, rl.MAROON)
        }
        frames_counter = 0
    }
}
draw_man_lives :: proc() {

    rl.DrawCircleLines(9*CELL_SIZE+2, 7*CELL_SIZE-5, 10, rl.LIGHTGRAY)         //
    rl.DrawCircleLines(9*CELL_SIZE+2, 7*CELL_SIZE-5, 9.75, rl.LIGHTGRAY)       //
    rl.DrawCircleLines(9*CELL_SIZE+2, 7*CELL_SIZE-5, 9.5, rl.LIGHTGRAY)        // Draw Head
    rl.DrawCircleLines(9*CELL_SIZE+2, 7*CELL_SIZE-5, 9.25, rl.LIGHTGRAY)       //
    rl.DrawCircleLines(9*CELL_SIZE+2, 7*CELL_SIZE-5, 9, rl.LIGHTGRAY)          //

    pos := Vec2 { 9*CELL_SIZE, 5*CELL_SIZE-2 }
    rect := rl.Rectangle {
        pos.x-1, pos.y+39,
        CELL_SIZE/2-2, CELL_SIZE+15
    }
    rl.DrawRectangleRec(rect, rl.LIGHTGRAY)                         // Draw Body

    arm_rect := rect
    arm_rect.x += -0.5
    arm_rect.y += 4
    arm_rect.width -= 1
    arm_rect.height -= 8
    r_leg_rect := arm_rect
    arm_rect.x += 4
    rl.DrawRectanglePro(arm_rect, { 0, 0 }, 135, rl.LIGHTGRAY)       // Draw Right Arm

    arm_rect.x += 3
    arm_rect.y += 3.5
    l_leg_rect := arm_rect
    l_leg_rect.x -= 4
    rl.DrawRectanglePro(arm_rect, { 0, 0 }, -135, rl.LIGHTGRAY)      // Draw Left Arm

    r_leg_rect.x += 1
    r_leg_rect.y += 22
    rl.DrawRectanglePro(r_leg_rect, { 0, 0 }, 45, rl.LIGHTGRAY)     //Draw Right Leg

    l_leg_rect.y += 22
    rl.DrawRectanglePro(l_leg_rect, { 0, 0 }, -45, rl.LIGHTGRAY)    // Draw Left Leg
}
draw_man :: proc() {

    if lives < 6 {
        rl.DrawCircleLines(9*CELL_SIZE+2, 5*CELL_SIZE-10, 10, rl.LIGHTGRAY)         //
        rl.DrawCircleLines(9*CELL_SIZE+2, 5*CELL_SIZE-10, 9.75, rl.LIGHTGRAY)       //
        rl.DrawCircleLines(9*CELL_SIZE+2, 5*CELL_SIZE-10, 9.5, rl.LIGHTGRAY)        // Draw Head
        rl.DrawCircleLines(9*CELL_SIZE+2, 5*CELL_SIZE-10, 9.25, rl.LIGHTGRAY)       //
        rl.DrawCircleLines(9*CELL_SIZE+2, 5*CELL_SIZE-10, 9, rl.LIGHTGRAY)          //
        pos := Vec2 { 9*CELL_SIZE, 2*CELL_SIZE+8 }

        if lives < 5 {
            rect := rl.Rectangle {
                pos.x-1, pos.y+39,
                CELL_SIZE/2-2, CELL_SIZE+15
            }
            rl.DrawRectangleRec(rect, rl.LIGHTGRAY)                                 // Draw Body

            if lives < 4 {
                arm_rect := rect
                arm_rect.x += -0.5
                arm_rect.y += 4
                arm_rect.width -= 1
                arm_rect.height -= 8
                r_leg_rect := arm_rect
                rl.DrawRectanglePro(arm_rect, { 0, 0 }, 45, rl.LIGHTGRAY)           // Draw Right Arm

                if lives < 3 {
                    arm_rect.x += 3
                    arm_rect.y += 3.5
                    l_leg_rect := arm_rect
                    rl.DrawRectanglePro(arm_rect, { 0, 0 }, -45, rl.LIGHTGRAY)      // Draw Left Arm

                    if lives < 2 {
                        r_leg_rect.x += 1
                        r_leg_rect.y += 22
                        rl.DrawRectanglePro(r_leg_rect, { 0, 0 }, 45, rl.LIGHTGRAY) //Draw Right Leg

                        if lives < 1 {
                            l_leg_rect.y += 22
                            rl.DrawRectanglePro(l_leg_rect, { 0, 0 }, -45, rl.LIGHTGRAY)    // Draw Left Leg
                        }
                    }
                }
            }
        }
    }
}
draw_board :: proc() {
    rect := rl.Rectangle {
        9*CELL_SIZE, 2*CELL_SIZE+8,
        CELL_SIZE/4, CELL_SIZE+5
    }
    rl.DrawRectangleRec(rect, rl.BROWN)     // draw rope

    pos := Vec2 { 5, GRID_WIDTH/2 }
    rect = rl.Rectangle {
        pos.x * CELL_SIZE, pos.y * CELL_SIZE,
        CELL_SIZE*6, CELL_SIZE/2
    }
    rl.DrawRectangleRec(rect, ORANGE_CLR)   // Draw base.

    pos += { 0, -7}                         // Move y position up 7.
    rect = rl.Rectangle {
        pos.x * CELL_SIZE+CELL_SIZE/2, pos.y * CELL_SIZE,
        CELL_SIZE/2, CELL_SIZE*7
    }
    rl.DrawRectangleRec(rect, ORANGE_CLR)   // Draw vertical pole.

    pos += { 0, -1 }                        // Move y position up 1.
    rect = rl.Rectangle {
        pos.x * CELL_SIZE+CELL_SIZE/2, pos.y * CELL_SIZE+CELL_SIZE/2,
        CELL_SIZE*4, CELL_SIZE/2
    }
    rl.DrawRectangleRec(rect, ORANGE_CLR)   // Draw top brace.

    if game_state == .Playing || 
        game_state == .Lost {
        draw_man()                              // Draw man.
    }
}
handle_input :: proc() {
    r := rl.GetCharPressed() 

    for r > 0 {                                                       
        if r >= 33 && r <= 125 && letter_count < MAX_INPUT {       
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

    if mouse_on_text {                                                  
        rl.SetMouseCursor(.IBEAM)                                       
        
    } else {                                                            
        rl.SetMouseCursor(.DEFAULT)                                     
    } 
    frames_counter += 1 
} 
check_input :: proc() {

    if letter_count > 0 {
        if guess_buff[0] >= 'A' && guess_buff[0] <= 'Z'{
            valid_guess = true
            guess = guess_buff[0] + 32

        } else if guess_buff[0] >= 'a' && guess_buff[0] <= 'z' {
            valid_guess = true
            guess = guess_buff[0]

        } else {
            valid_guess = false
        }  
    }
    if valid_guess {
        if rl.IsKeyPressed(.ENTER) {
            if !seen_runes[guess] {
                seen_runes[guess] = true
                tmp := rune(guess)

                if strings.contains_rune(answer, tmp) {
                    place_found_rune(tmp)
                    guess_buff[0] = 0
                    letter_count = 0
                } else {
                    fmt.printfln("%c Not in %s\nKey: %v", guess_buff[0], answer, key)
                    guess_buff[0] = 0
                    letter_count = 0
                    lives -= 1
                }
            } else {
              guess_buff[0] = 0
              letter_count = 0
            }
        }
    } else {

        if rl.IsKeyPressed(.ENTER) {
            guess_buff[0] = 0
            letter_count = 0
        }
    }   
}
place_found_rune :: proc(find: rune) {
    indx: int

    for r in answer {
        if find == r {

            if contains_space {
                if (indx*2)-1 >= space_indx {
                    ans_board[(indx*2)-1] = byte(r)
                } else {
                    ans_board[indx*2] = byte(r)
                }
            } else {
                ans_board[indx*2] = byte(r)
            }
            correct += 1
            //fmt.printfln("%r Found in %s at position %v", find, answer, indx+1)
        }
        indx += 1
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

    if game_start {
        delete(ans_board)
        delete_map(seen_runes)
    }

    key = random_num(0, BANK_SIZE-2)
    
    if debug {
        key = BANK_SIZE-1
    }
    
    guess_buff[0] = 0
    answer = word_bank[key]
    leng = len(answer)
    lives = 6
    correct = 0
    game_state = .Playing
    contains_space = strings.contains_space(answer)
    ans_board = make([]byte, leng+(leng-1), context.allocator)

    if contains_space {
        space_indx = strings.index_rune(answer, ' ')
        leng -= 1
    }

    for i: int; i < len(ans_board); i += 2 {
        if i-1 == (space_indx*2)-1 && contains_space {

            ans_board[i] = 32
            ans_board[i+1] = 32
            space_indx = i
            i -= 1
            continue
        }
        // Using underscore for a blank space.
        ans_board[i] = '_'
        // Adding blank space between `_`'s
        if i != len(ans_board)-1 {
            ans_board[i+1] = 32
        }
    }
    seen_runes = {}
}