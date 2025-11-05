package day6_2024

import "core:fmt"
import "core:mem"
import "core:os"
import "core:strings"

int2 :: [2]int

UP :: -1
DOWN :: 1
LEFT :: -1
RIGHT :: 1

Direction :: enum {
    Up,
    Down,
    Left,
    Right,
}

main :: proc() {
    when ODIN_DEBUG {
        track1: mem.Tracking_Allocator
        track2: mem.Tracking_Allocator
        mem.tracking_allocator_init(&track1, context.allocator)
        mem.tracking_allocator_init(&track2, context.temp_allocator)
        context.allocator = mem.tracking_allocator(&track1)
        context.temp_allocator = mem.tracking_allocator(&track2)
        defer {
            if len(track1.allocation_map) > 0 {
                for _, entry in track1.allocation_map {
                    fmt.eprintf("%v leaked %v bytes\n", entry.location, entry.size)
                }
            }
            if len(track2.allocation_map) > 0 {
                for _, entry in track2.allocation_map {
                    fmt.eprintf("%v leaked %v bytes\n", entry.location, entry.size)
                }
            }
            mem.tracking_allocator_destroy(&track1)
            mem.tracking_allocator_destroy(&track2)
        }
    }

    file, ok := os.read_entire_file("input", context.temp_allocator)
    checkOk(ok)

    fileStr := string(file)
    labMap := make([dynamic]string, context.temp_allocator)
    for str in strings.split_lines_iterator(&fileStr) {
        append(&labMap, str)
    }

    curPos := guardLoc(&labMap)
    seenLocs := make(map[int2]bool, context.temp_allocator)
    defer free_all(context.temp_allocator)
    seenLocs[curPos] = true
    total1 := 1
    dir: Direction = .Up

    search: for {

        switch dir {

            case .Up:
                // Check if way forward is clear
                if labMap[curPos.x + UP][curPos.y] != '#' {
                    // If clear, move curPos forward
                    curPos.x += UP
                    // Check if we've been to this spot
                    if !seenLocs[curPos] {
                        total1 += 1
                        seenLocs[curPos] = true
                    }
                    // Check if we are pass the edge
                    if curPos.x >= len(labMap) - 1 || curPos.x <= 0 {
                        break search
                    }
                } else {
                    dir = .Right
                }

            case .Down:
                if labMap[curPos.x + DOWN][curPos.y] != '#' {
                    curPos.x += DOWN
                    if !seenLocs[curPos] {
                        total1 += 1
                        seenLocs[curPos] = true
                    }
                    if curPos.x >= len(labMap) - 1 || curPos.x <= 0 {
                        break search
                    }
                } else {
                    dir = .Left
                }

            case .Left:
                if labMap[curPos.x][curPos.y + LEFT] != '#' {
                    curPos.y += LEFT
                    if !seenLocs[curPos] {
                        total1 += 1
                        seenLocs[curPos] = true
                    }
                    if curPos.y >= len(labMap[0]) || curPos.y <= 0 {
                        break search
                    }
                } else {
                    dir = .Up
                }

            case .Right:
                if labMap[curPos.x][curPos.y + RIGHT] != '#' {
                    curPos.y += RIGHT
                    if !seenLocs[curPos] {
                        total1 += 1
                        seenLocs[curPos] = true
                    }
                    if curPos.y >= len(labMap[0]) || curPos.y <= 0 {
                        break search
                    }
                } else {
                    dir = .Down
                }
        }
    }
    fmt.println("Part 1 answer:", total1) // 5534
}
guardLoc :: proc(labMap: ^[dynamic]string) -> int2 {
    for str, x in labMap {
        for r, y in str {
            if r != '.' && r != '#' {
                return int2{x, y}
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
