package day6_2024

import "core:fmt"
import "core:os"
import "core:strings"

int2 :: [2]int

Guard :: struct {
    loc: int2,
    dir: rune,
}
UP: int : -1
DOWN: int : 1
LEFT: int : -1
RIGHT: int : 1
Up :: '^'
Down :: 'v'
Left :: '<'
Right :: '>'

main :: proc() {
    file, ok := os.read_entire_file("input")
    checkOk(ok)
    fileStr := string(file)
    layout := make([dynamic]string, context.temp_allocator)
    for str in strings.split_lines_iterator(&fileStr) {
        append(&layout, str)
    }
    guard: Guard
    guard.dir = Up
    guard.loc = guardLoc(&layout)
    total1: int

    fmt.println(guard.loc)
    for guard.loc.x > 0 &&
        guard.loc.x < len(layout) - 1 &&
        guard.loc.y > 0 &&
        guard.loc.y < len(layout) - 1 {

        fmt.println(guard.loc, guard.dir)
        switch guard.dir {
            case Up:
                if layout[guard.loc.x][guard.loc.y + UP] != '#' {
                    total1 += 1
                    guard.loc.y += UP
                } else {
                    guard.dir = Right
                }
            case Down:
                if layout[guard.loc.x][guard.loc.y + DOWN] != '#' {
                    total1 += 1
                    guard.loc.y += DOWN
                } else {
                    guard.dir = Left
                }
            case Left:
                // fmt.println(guard.loc.x)
                if layout[guard.loc.x + LEFT][guard.loc.y] != '#' {
                    total1 += 1
                    guard.loc.x += LEFT
                } else {
                    guard.dir = Up
                }
            case Right:
                if layout[guard.loc.x + RIGHT][guard.loc.y] != '#' {
                    total1 += 1
                    guard.loc.x += RIGHT
                } else {
                    guard.dir = Down
                }
        }
    }
    fmt.println(total1) // 140 too low
}
guardLoc :: proc(layout: ^[dynamic]string) -> int2 {
    for i in 0 ..< len(layout) {
        for j in 0 ..< len(layout[i]) {
            if layout[i][j] == '^' {
                return int2({j, i})
            }
        }
    }
    return {0, 0}
}
checkOk :: proc(ok: bool, loc := #caller_location) {
    if !ok {
        panic("Somthing wasn't ok", loc)
    }
}
