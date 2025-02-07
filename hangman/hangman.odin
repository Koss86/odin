package hangman

import rl "vendor:raylib"
import "core:fmt"
import "core:os"

WINDOW_SIZE :: 920
GRID_SIZE :: 20
CELL_SIZE :: 16
SCREEN_SIZE :: GRID_SIZE*CELL_SIZE


main :: proc() {

    rl.SetConfigFlags({.VSYNC_HINT})
    rl.InitWindow(WINDOW_SIZE, WINDOW_SIZE, "Hangman")
    //rl.InitAudioDevice()
    camera := rl.Camera2D {
        zoom = f32(WINDOW_SIZE)/SCREEN_SIZE
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