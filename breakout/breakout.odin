package breakout

import rl "vendor:raylib"
import "core:math"
import "core:math/linalg"


main :: proc() {
    rl.InitWindow(1280, 1280, "Breakout!")

    for !rl.WindowShouldClose() {
        rl.BeginDrawing()

        rl.EndDrawing()
    }
    rl.CloseWindow()
}