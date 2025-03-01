package hangman
import "core:os"
import "core:fmt"
import "core:math/rand"
import "core:bytes"
import "core:strconv"
import "core:strings"
import "core:sys/info"
import rl "vendor:raylib"

Vec2 :: rl.Vector2
WINDOW_SIZE :: 920
GRID_WIDTH :: 20
CELL_SIZE :: 16
CANVAS_SIZE :: GRID_WIDTH*CELL_SIZE
LINUX_NUM :: 40
WINDOWS_NUM :: 40
SPACE :: 32
BANK_SIZE :: 20
MAX_INPUT :: 1

key: i32
indx: int
guesses: int
correct: int
answer: cstring
game_over: bool
game_start: bool
word_bank: [BANK_SIZE] string
guess: [MAX_INPUT]byte
c_guess: cstring
letter_count: i32
mouse_on_text: bool
frames_counter: int
valid_guess: bool

random_num :: proc(min: int, max: int) -> i32 {
    min := i32(min)
    max := i32(max)
    seed := rand.uint32()
    rl.SetRandomSeed(seed)
    return rl.GetRandomValue(min, max)
}
game_state :: proc() {
    key = random_num(0, BANK_SIZE-1)
    answer = strings.clone_to_cstring(word_bank[key], context.allocator)
    guesses = 6
    correct = 0
    game_over = false
}

main :: proc() {
    buff, ok := os.read_entire_file("word_bank.txt", context.allocator)

    input := string(buff)
    for str in strings.split_iterator(&input, ",") {
        word_bank[indx] = strings.clone(str, context.allocator)
        indx += 1
    }
    delete(buff)
    
    game_state()
    divide_frames: int
    os_platform := info.os_version.platform
    #partial switch os_platform {
        case .Linux:
        divide_frames = LINUX_NUM
        case .Windows:
        divide_frames = WINDOWS_NUM
        case:
        panic("Error. Unknown OS.")
    }

    camera := rl.Camera2D {
        zoom = f32(WINDOW_SIZE)/CANVAS_SIZE
    }
    text_box := rl.Rectangle {
        8*CELL_SIZE , 12*CELL_SIZE,
        CELL_SIZE-4, CELL_SIZE-4 
    }
    collision_box := rl.Rectangle {
        367, 550,
        50, 50
    }

    rl.SetConfigFlags({.VSYNC_HINT})
    rl.InitWindow(WINDOW_SIZE, WINDOW_SIZE, "Hangman")

    rl.SetTargetFPS(60)
    
    for !rl.WindowShouldClose() {

/////////////////////// Update input box /////////////////////////////////////
        mouse_pos := rl.GetMousePosition()
        if rl.CheckCollisionPointRec(mouse_pos, collision_box) {            
            mouse_on_text = true                                            
        } else {                                                            
            mouse_on_text = false                                           
        }                                                                   

        r := rl.GetCharPressed()   
        for r > 0 {                                                       
            if r >= 33 && r <= 125 && letter_count < MAX_INPUT {        
                guess[letter_count] = u8(r)                               
                letter_count += 1                                           
            }                                                               
            r = rl.GetCharPressed()                                       
        }                                                                   
                                                                            
        if rl.IsKeyPressed(.BACKSPACE) {                                    
            letter_count -= 1                                               
            if letter_count < 0 {                                           
                letter_count = 0                                            
            }                                                               
            guess[letter_count] = 0                                         
        }
        //////////// Check guess ////////////
        if letter_count > 0 {
            tmp := strings.to_lower(string(guess[:]), context.temp_allocator)
            if tmp[0] >= 'a' && tmp[0] <= 'z' {
                valid_guess = true
                fmt.println(string(tmp))
            } else {
                valid_guess = false
            }
        }
        if valid_guess {
            //fmt.println(string(guess[:]))
        }                                                              
        if mouse_on_text {                                                  
            rl.SetMouseCursor(.IBEAM)                                       
                                                                            
        } else {                                                            
            rl.SetMouseCursor(.DEFAULT)                                     
        }                                                 
        frames_counter += 1                                             
//////////////////////////////////////////////////////////////////////////////

        rl.BeginDrawing()
            rl.ClearBackground({ 15, 30, 175, 255 })
            rl.BeginMode2D(camera)
            //rl.ClearBackground(rl.BLUE)

            if !game_start {
                rl.DrawText("Welcome to Hangman!", 38, 15, 25, { 210, 100, 75, 255 })
                rl.DrawText("Press SPACE to begin.", 96, 40, 9, { 210, 100, 75, 255 })
                if rl.IsKeyPressed(.SPACE) {
                    game_start = true
                }
            } else {
                pos := Vec2 { 5, GRID_WIDTH/2 }
                rect := rl.Rectangle {
                    pos.x * CELL_SIZE, pos.y * CELL_SIZE,
                    CELL_SIZE*6, CELL_SIZE/2
                }
                rl.DrawRectangleRec(rect, { 210, 100, 75, 255 }) // Draw base.

                pos += { 0, -7}                                  // Move y position up 7.
                rect = rl.Rectangle {
                    pos.x * CELL_SIZE+CELL_SIZE/2, pos.y * CELL_SIZE,
                    CELL_SIZE/2, CELL_SIZE*7
                }
                rl.DrawRectangleRec(rect, { 210, 100, 75, 255 }) // Draw vertical pole.

                pos += { 0, -1 }                                 // Move y position up 1.
                rect = rl.Rectangle {
                    pos.x * CELL_SIZE+CELL_SIZE/2, pos.y * CELL_SIZE+CELL_SIZE/2,
                    CELL_SIZE*4, CELL_SIZE/2
                }
                rl.DrawRectangleRec(rect, { 210, 100, 75, 255 }) // Draw top brace.


                /////////////////////////////////////// Draw Input Box /////////////////////////////////////////////////
                rl.DrawRectangleRec(text_box, rl.LIGHTGRAY)
                rl.DrawRectangleLines(i32(text_box.x), i32(text_box.y), i32(text_box.width), i32(text_box.height), rl.RED)

                tmp := string(guess[:])
                c_guess = strings.clone_to_cstring(tmp, context.temp_allocator)

                rl.DrawText(c_guess, i32(text_box.x)+2, i32(text_box.y)+1, 9, rl.MAROON)
                rl.DrawText(rl.TextFormat("Attempts/Total:\n %i/%i", correct, len(answer)), 101, 175, 10, rl.DARKGRAY)

                if letter_count < MAX_INPUT {
                    if (frames_counter/40)%2 == 0 {
                        rl.DrawText("_", i32(text_box.x) + 2 + rl.MeasureText(c_guess, 9), i32(text_box.y) + 3, 9, rl.MAROON)
                    } 
                } else {
                    rl.DrawText("Press BACKSPACE to delete chars or ENTER to confirm...", 10, 215, 5, rl.GRAY)
                    frames_counter = 0
                }

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
            }
            free_all(context.temp_allocator)
            rl.EndMode2D()
        rl.EndDrawing()
    }
    rl.CloseWindow()
}