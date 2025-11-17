package day6_2024
import "core:fmt"
import "core:os"
import "core:strings"

int2 :: [2]int
UP :: int2{-1, 0}
DOWN :: int2{1, 0}
LEFT :: int2{0, -1}
RIGHT :: int2{0, 1}
Direction :: enum {
    Up,
    Down,
    Left,
    Right,
}

main :: proc() {
    context.allocator = context.temp_allocator
    file, ok := os.read_entire_file("input")
    checkOk(ok)

    fileStr := string(file)
    labMap := make([dynamic]string)
    for str in strings.split_lines_iterator(&fileStr) {
        append(&labMap, str)
    }

    seenLocs := make(map[int2]bool)
    grdDirMap := make(map[int2]Direction)
    defer free_all(context.temp_allocator)
    xyMax: int2 = {len(labMap), len(labMap[0])}
    curPos := guardLoc(&labMap)
    dir: Direction = .Up
    grdDirMap[curPos] = .Up
    seenLocs[curPos] = true

    for curPos.x > 0 && curPos.x < xyMax.x - 1 && curPos.y > 0 && curPos.y < xyMax.y - 1 {
        switch dir {
            case .Up:
                // Check if way forward is clear
                if labMap[curPos.x + UP.x][curPos.y] != '#' {
                    // If clear, move curPos forward
                    curPos += UP
                    // Check if we've been to this spot
                    if !seenLocs[curPos] {
                        seenLocs[curPos] = true
                        // Save what direction the guard was going.
                        grdDirMap[curPos] = .Up
                    }
                } else {
                    dir = .Right
                }

            case .Down:
                if labMap[curPos.x + DOWN.x][curPos.y] != '#' {
                    curPos += DOWN
                    if !seenLocs[curPos] {
                        seenLocs[curPos] = true
                        grdDirMap[curPos] = .Down
                    }
                } else {
                    dir = .Left
                }

            case .Left:
                if labMap[curPos.x][curPos.y + LEFT.y] != '#' {
                    curPos += LEFT
                    if !seenLocs[curPos] {
                        seenLocs[curPos] = true
                        grdDirMap[curPos] = .Left
                    }
                } else {
                    dir = .Up
                }

            case .Right:
                if labMap[curPos.x][curPos.y + RIGHT.y] != '#' {
                    curPos += RIGHT
                    if !seenLocs[curPos] {
                        seenLocs[curPos] = true
                        grdDirMap[curPos] = .Right
                    }
                } else {
                    dir = .Down
                }
        }
    }
    fmt.println("Part 1 answer:", len(seenLocs)) // 5534

    total: int
    // Search seenLocs (guard's potrol path) for potential loops
    for key, value in seenLocs {
        if value {
            if testForLoop(&labMap, key, grdDirMap[key]) {
                total += 1
            }
        }
    }
    fmt.println("Part 2 answer:", total) // 2262
}

testForLoop :: proc(labMap: ^[dynamic]string, objPos: int2, dir: Direction) -> bool {
    dir := dir
    curPos: int2
    switch dir {
        case .Up:
            // Move curPos back 1 from new object
            curPos = objPos + DOWN
            // Turn direction
            dir = .Right

        case .Down:
            curPos = objPos + UP
            dir = .Left

        case .Left:
            curPos = objPos + RIGHT
            dir = .Up

        case .Right:
            curPos = objPos + LEFT
            dir = .Down
    }

    loop: int
    LIMIT :: 100
    seenLocs := make(map[int2]bool)
    seenLocs[curPos] = true
    xyMax: int2 = {len(labMap), len(labMap[objPos.x])}
    for curPos.x > 0 && curPos.x < xyMax.x - 1 && curPos.y > 0 && curPos.y < xyMax.y - 1 {
        switch dir {

            case .Up:
                if labMap[curPos.x + UP.x][curPos.y] != '#' && curPos + UP != objPos {
                    curPos += UP
                } else {
                    dir = .Right
                }

            case .Down:
                if labMap[curPos.x + DOWN.x][curPos.y] != '#' && curPos + DOWN != objPos {
                    curPos += DOWN
                } else {
                    dir = .Left
                }

            case .Left:
                if labMap[curPos.x][curPos.y + LEFT.y] != '#' && curPos + LEFT != objPos {
                    curPos += LEFT
                } else {
                    dir = .Up
                }

            case .Right:
                if labMap[curPos.x][curPos.y + RIGHT.y] != '#' && curPos + RIGHT != objPos {
                    curPos += RIGHT
                } else {
                    dir = .Down
                }
        }
        if !seenLocs[curPos] {
            seenLocs[curPos] = true
            loop = 0
        } else {
            loop += 1
        }
        if loop > LIMIT {
            delete(seenLocs)
            return true
        }
    }
    delete(seenLocs)
    return false
}
guardLoc :: proc(labMap: ^[dynamic]string) -> int2 {
    for str, x in labMap {
        for r, y in str {
            if r != '.' && r != '#' {
                return int2{x, y}
            }
        }
    }
    panic("Couldn't find guard location.")
}
checkOk :: proc(ok: bool, loc := #caller_location) {
    if !ok {
        panic("Somthing wasn't ok", loc)
    }
}
