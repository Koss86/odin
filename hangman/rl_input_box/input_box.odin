package input_box
import rl "vendor:raylib"
import "core:fmt"
import "core:strings"

MAX_INPUT :: 9

main :: proc() {
    screen_width: i32 = 800
    screen_height: i32 = 450

    rl.InitWindow(screen_width, screen_height, "raylib [text] example - input box coded in Odin")
    
    name: [MAX_INPUT]byte
    c_name: cstring
    letter_count: i32

    text_box := rl.Rectangle {
        f32(screen_width)/2 - 100, 180,
        225, 50 
    }
    mouse_on_text: bool
    frames_counter: i32

    for !rl.WindowShouldClose() {

        if rl.CheckCollisionPointRec(rl.GetMousePosition(), text_box) {
            mouse_on_text = true
        } else { 
            mouse_on_text = false 
        } 
        
        if mouse_on_text {
            rl.SetMouseCursor(.IBEAM)
            key := rl.GetCharPressed()
            
            for key > 0 {
                if key >= 32 && key <= 125 && letter_count < MAX_INPUT {
                    name[letter_count] = u8(key)
                    letter_count += 1
                }
                key = rl.GetCharPressed()
            }

            if rl.IsKeyPressed(.BACKSPACE) {
                letter_count -= 1
                if letter_count < 0 { 
                    letter_count = 0 
                }
                name[letter_count] = 0
            }
        } else { 
            rl.SetMouseCursor(.DEFAULT) 
        }

        if mouse_on_text { 
            frames_counter += 1 
        } else { 
            frames_counter = 0 
        }

        rl.BeginDrawing()
            rl.ClearBackground(rl.WHITE)

            rl.DrawText("Place Mouse Over Input Box!", 240, 140, 20, rl.GRAY)

            rl.DrawRectangleRec(text_box, rl.LIGHTGRAY)
            if mouse_on_text {
                rl.DrawRectangleLines(i32(text_box.x), i32(text_box.y), i32(text_box.width), i32(text_box.height), rl.RED)
            } else {
                rl.DrawRectangleLines(i32(text_box.x), i32(text_box.y), i32(text_box.width), i32(text_box.height), rl.DARKGRAY)
            }

            tmp := string(name[:])
            c_name = strings.clone_to_cstring(tmp, context.temp_allocator)

            rl.DrawText(c_name, i32(text_box.x)+5, i32(text_box.y)+8, 40, rl.MAROON)
            rl.DrawText(rl.TextFormat("Input Chars: %i/%i", letter_count, MAX_INPUT), 315, 250, 20, rl.DARKGRAY)

            if mouse_on_text {
                if letter_count < MAX_INPUT {
                    if (frames_counter/900)%2 == 0 {
                        rl.DrawText("_", i32(text_box.x) + 8 + rl.MeasureText(c_name, 40), i32(text_box.y) + 12, 40, rl.MAROON)
                    } 
                } else {
                    rl.DrawText("Press BACKSPACE to delete chars...", 230, 300, 20, rl.GRAY)
                }
            }
            free_all(context.temp_allocator)
        rl.EndDrawing()
    }
    rl.CloseWindow()
}