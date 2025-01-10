package hangman

import rl "vendor:raylib"
import "core:fmt"
import "core:os"

GRID_SIZE :: 20
CELL_SIZE :: 16
WINDOW_SIZE :: GRID_SIZE*CELL_SIZE


main :: proc() {

    rl.SetConfigFlags({.VSYNC_HINT})
    rl.InitWindow(960, 960, "Hangman")
    //rl.InitAudioDevice()
    camera := rl.Camera2D {
        zoom = f32(WINDOW_SIZE)
    }



    for !rl.WindowShouldClose() {
        rl.BeginMode2D(camera)
        rl.BeginDrawing()
        rl.ClearBackground({150, 180, 200, 255})

        

        rl.EndMode2D()
        rl.EndDrawing()
    }

    //rl.CloseAudioDevice()
    rl.CloseWindow()
}