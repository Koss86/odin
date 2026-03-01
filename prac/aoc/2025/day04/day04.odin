package day4_2025

import "core:fmt"
import "core:os"
import "core:strings"

Vec2 :: [2]int
UP :: Vec2{0, -1}
DOWN :: Vec2{0, 1}
LEFT :: Vec2{-1, 0}
RIGHT :: Vec2{1, 0}
RIGHT_UP :: Vec2{1, -1}
LEFT_UP :: Vec2{-1, -1}
RIGHT_DOWN :: Vec2{1, 1}
LEFT_DOWN :: Vec2{-1, 1}

main :: proc() {
    file, err := os.read_entire_file_from_path("input", context.allocator)
    check_err(err)
    str_file := string(file)
    Map: [dynamic]string
    for line in strings.split_lines_iterator(&str_file) {
        append(&Map, line)
    }
    open_space: map[Vec2]bool
    for row, y in Map {
        for col, x in row {
            if col == '.' {
                open_space[{x, y}] = true
            }
        }
    }
    defer {
        delete(file)
        delete(Map)
        delete(open_space)
        free_all(context.temp_allocator)
    }

    // Set "out of bounds" areas on the left and right as open space
    for i in 0 ..< len(Map) {
        open_space[{-1, i}] = true
        open_space[{len(Map), i}] = true
    }

    accessible_rolls: int
    for row, y in Map {
        for col, x in row {
            if !open_space[{x, y}] && isAccessible(&Map, &open_space, {x, y}) {
                accessible_rolls += 1
            }
        }
    }

    removed_rolls := removeRolls(&Map, &open_space)
    fmt.println("Part 1 answer:", accessible_rolls)
    fmt.println("Part 2 answer:", removed_rolls)
}
removeRolls :: proc(Map: ^[dynamic]string, open_space: ^map[Vec2]bool) -> int {
    removed_rolls: int
    for row, y in Map {
        for col, x in row {
            if !open_space[{x, y}] && isAccessible(Map, open_space, {x, y}) {
                removed_rolls += 1
                open_space[{x, y}] = true
            }
        }
    }
    if removed_rolls == 0 {
        return 0
    }
    return removed_rolls + removeRolls(Map, open_space)
}
isAccessible :: proc(Map: ^[dynamic]string, open_space: ^map[Vec2]bool, pos: Vec2) -> bool {
    occupied: int
    switch pos.y {
        case 0:
            if !open_space[pos + DOWN] { occupied += 1 }
            if !open_space[pos + LEFT] { occupied += 1 }
            if !open_space[pos + RIGHT] { occupied += 1 }
            if !open_space[pos + LEFT_DOWN] { occupied += 1 }
            if !open_space[pos + RIGHT_DOWN] { occupied += 1 }
        case len(Map) - 1:
            if !open_space[pos + UP] { occupied += 1 }
            if !open_space[pos + LEFT] { occupied += 1 }
            if !open_space[pos + RIGHT] { occupied += 1 }
            if !open_space[pos + LEFT_UP] { occupied += 1 }
            if !open_space[pos + RIGHT_UP] { occupied += 1 }
        case:
            if !open_space[pos + UP] { occupied += 1 }
            if !open_space[pos + DOWN] { occupied += 1 }
            if !open_space[pos + LEFT] { occupied += 1 }
            if !open_space[pos + RIGHT] { occupied += 1 }
            if !open_space[pos + LEFT_UP] { occupied += 1 }
            if !open_space[pos + RIGHT_UP] { occupied += 1 }
            if !open_space[pos + LEFT_DOWN] { occupied += 1 }
            if !open_space[pos + RIGHT_DOWN] { occupied += 1 }
    }
    if occupied < 4 {
        return true
    }
    return false
}
checkOk :: proc(ok: bool, loc := #caller_location) {
    if !ok {
        panic("Somthing's not ok.", loc)
    }
}

check_err :: proc(err: os.Error, loc := #caller_location) {
    if err != nil {
        fmt.println("error:", err)
        panic("", loc)
    }
}
