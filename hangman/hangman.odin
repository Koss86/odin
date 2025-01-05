package hangman

import rl "vendor:raylib"
import "core:fmt"


main :: proc() {

    rl.SetConfigFlags({.VSYNC_HINT})
    rl.InitWindow(800, 600, "Hangman")
    //rl.InitAudioDevice()

    for !rl.WindowShouldClose() {

        rl.BeginDrawing()
        rl.ClearBackground({150, 180, 200, 255})


        rl.EndDrawing()
    }

    //rl.CloseAudioDevice()
    rl.CloseWindow()
}