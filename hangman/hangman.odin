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
LINUX_NUM_RETURNS :: 2
WINDOWS_NUM_RETURNS :: 3
SPACE :: 32
BANK_SIZE :: 20
MAX_INPUT :: 1

key: i32
indx: int
guesses: int
correct: int
answer: string
game_over: bool
game_start: bool
word_bank: [BANK_SIZE] string
name: [MAX_INPUT]byte
c_name: cstring
letter_count: i32
mouse_on_text: bool
frames_counter: i32

random_num :: proc(min: int, max: int) -> i32 {
    min := i32(min)
    max := i32(max)
    seed := rand.uint32()
    rl.SetRandomSeed(seed)
    return rl.GetRandomValue(min, max)
}
game_state :: proc() {
    key = random_num(0, BANK_SIZE-1)
    answer = word_bank[key]
    guesses = 6
    correct = 0
    indx = 0
    game_over = false
}

main :: proc() {
    buff, ok := os.read_entire_file("word_bank.txt", context.allocator)

    input := string(buff)
    for str in strings.split_iterator(&input, ",") {
        word_bank[indx] = strings.clone(str, context.allocator)
        indx += 1
    }
    
    game_state()
    expected_leng: int
    os_platform := info.os_version.platform
    #partial switch os_platform {
        case .Linux:
        expected_leng = LINUX_NUM_RETURNS
        case .Windows: 
        expected_leng = WINDOWS_NUM_RETURNS
        case:
        fmt.printfln("Error. Unknown OS.")
        return
    }

    camera := rl.Camera2D {
        zoom = f32(WINDOW_SIZE)/CANVAS_SIZE
    }
    text_box := rl.Rectangle {
        10*CELL_SIZE , 11*CELL_SIZE,
        125, 50 
    }
    
    rl.SetConfigFlags({.VSYNC_HINT})
    rl.InitWindow(WINDOW_SIZE,WINDOW_SIZE, "Hangman")

    for !rl.WindowShouldClose() {

/////////////////////// Update input box /////////////////////////////////////
        if rl.CheckCollisionPointRec(rl.GetMousePosition(), text_box) {     //
            mouse_on_text = true                                            //
        } else {                                                            //
            mouse_on_text = false                                           //
        }                                                                   //
                                                                            //
        if mouse_on_text {                                                  //
            rl.SetMouseCursor(.IBEAM)                                       //
            key := rl.GetCharPressed()                                      //
                                                                            //
            for key > 0 {                                                   //
                if key >= 32 && key <= 125 && letter_count < MAX_INPUT {    //
                    name[letter_count] = u8(key)                            //
                    letter_count += 1                                       //
                }                                                           //
                key = rl.GetCharPressed()                                   //
            }                                                               //
                                                                            //
            if rl.IsKeyPressed(.BACKSPACE) {                                //
                letter_count -= 1                                           //
                if letter_count < 0 {                                       //
                    letter_count = 0                                        //
                }                                                           //
                name[letter_count] = 0                                      //
            }                                                               //
        } else {                                                            //
            rl.SetMouseCursor(.DEFAULT)                                     //
        }                                                                   //
                                                                            //
        if mouse_on_text {                                                  //
            frames_counter += 1                                             //
        } else {                                                            //
            frames_counter = 0                                              //
        }                                                                   //
//////////////////////////////////////////////////////////////////////////////

        rl.BeginDrawing()
            rl.BeginMode2D(camera)
            rl.ClearBackground({ 15, 30, 175, 255 })
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


/////////////////////////////// Draw Input Box ////////////////////////////////////////

                rl.DrawRectangleRec(text_box, rl.LIGHTGRAY)

                if mouse_on_text {
                    rl.DrawRectangleLines(i32(text_box.x), i32(text_box.y), i32(text_box.width), i32(text_box.height), rl.RED)
                } else {
                    rl.DrawRectangleLines(i32(text_box.x), i32(text_box.y), i32(text_box.width), i32(text_box.height), rl.DARKGRAY)
                }

                tmp := string(name[:])
                c_name = strings.clone_to_cstring(tmp, context.temp_allocator)

                rl.DrawText(c_name, i32(text_box.x)+2, i32(text_box.y)+4, 40, rl.MAROON)
                rl.DrawText(rl.TextFormat("Input Chars: %i/%i", letter_count, MAX_INPUT), 315, 250, 20, rl.DARKGRAY)

                if mouse_on_text {
                    if letter_count < MAX_INPUT {
                        if (frames_counter/900)%2 == 0 {
                            rl.DrawText("_", i32(text_box.x) + 8 + rl.MeasureText(c_name, 9), i32(text_box.y) + 12, 9, rl.MAROON)
                        } 
                    } else {
                        rl.DrawText("Press BACKSPACE to delete chars...", 230, 300, 20, rl.GRAY)
                    }
                }
            }
            rl.EndMode2D()
        rl.EndDrawing()
    }
    rl.CloseWindow()

    /*
    fmt.print("Guess a letter: ")
    num_of_stdin, _ := os.read(os.stdin, buff[:])
    for num_of_stdin != expected_leng || 
        buff[0] == SPACE || 
        buff[0] >= '0' && buff[0] <= '9' {
        fmt.printf("\nPlease guess one letter only, no spaces or numbers.\n\nGuess a letter: ")
        num_of_stdin, _ = os.read(os.stdin, buff[:])
    }

    tmp_str := string(buff[:])
    
    #partial switch os_platform {
        case .Linux:
        indx = bytes.index_byte(buff[:], 10)
        case .Windows: 
        indx = bytes.index_byte(buff[:], 13)
    }
    guess := tmp_str[:indx]
    fmt.println(guess)
    */
}