package main

import "core:fmt"
import "core:os"

main :: proc() {
    h := 10
    w := 10
    for i := 0; i < h; i += 1 { 
        for j := 0; j < w; j += 1 {
            fmt.printf("#")
        }
        fmt.printf("\n")
    }
}