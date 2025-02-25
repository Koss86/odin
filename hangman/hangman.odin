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

key: i32
indx: int
guesses: int
correct: int
answer: string
game_over: bool
game_start: bool
word_bank: [BANK_SIZE] string

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
    rl.SetConfigFlags({.VSYNC_HINT})
    rl.InitWindow(WINDOW_SIZE,WINDOW_SIZE, "Hangman")
    for !rl.WindowShouldClose() {
        rl.BeginDrawing()
            rl.BeginMode2D(camera)
            rl.ClearBackground({ 15, 30, 175, 255 })
            if !game_start {
                rl.DrawText("Welcome to Hangman!", 38, 15, 25, rl.ORANGE)
                rl.DrawText("Press SPACE to begin.", 96, 40, 9, rl.ORANGE)
                if rl.IsKeyPressed(.SPACE) {
                    game_start = true
                }
            }
            if game_start {
               pos := Vec2 { GRID_WIDTH/2, GRID_WIDTH/2 }
                rect := rl.Rectangle {
                    pos.x * CELL_SIZE, pos.y * CELL_SIZE,
                    CELL_SIZE, CELL_SIZE
            }
            rl.DrawRectangleRec(rect, rl.ORANGE) 
            }
            

            rl.EndMode2D()
        rl.EndDrawing()
    }
    rl.CloseWindow()

    /*
    fmt.print("Guess a letter: ")
    num_of_stdin, _ := os.read(os.stdin, buff[:])
    for num_of_stdin != expected_leng || buff[0] == SPACE || 
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