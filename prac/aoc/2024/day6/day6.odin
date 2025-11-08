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

    curPos := guardLoc(&labMap)
    dir: Direction = .Up
    seenLocs := make(map[int2]bool)
    usedLocs := make(map[int2]bool)
    defer free_all(context.temp_allocator)
    xyRange: int2 = {len(labMap), len(labMap[0])}
    seenLocs[curPos] = true
    total1 := 1

    for curPos.x > 0 && curPos.x < xyRange.x - 1 && curPos.y > 0 && curPos.y < xyRange.y - 1 {

        switch dir {

            case .Up:
                // Check if way forward is clear
                if labMap[curPos.x + UP.x][curPos.y] != '#' {
                    // If clear, move curPos forward
                    curPos += UP
                    // Check if we've been to this spot
                    if !seenLocs[curPos] {
                        total1 += 1
                        seenLocs[curPos] = true
                    }
                } else {
                    // Set to used where objects already are
                    usedLocs[curPos + UP] = true
                    dir = .Right
                }

            case .Down:
                if labMap[curPos.x + DOWN.x][curPos.y] != '#' {
                    curPos += DOWN
                    if !seenLocs[curPos] {
                        total1 += 1
                        seenLocs[curPos] = true
                    }
                } else {
                    usedLocs[curPos + DOWN] = true
                    dir = .Left
                }

            case .Left:
                if labMap[curPos.x][curPos.y + LEFT.y] != '#' {
                    curPos += LEFT
                    if !seenLocs[curPos] {
                        total1 += 1
                        seenLocs[curPos] = true
                    }
                } else {
                    usedLocs[curPos + LEFT] = true
                    dir = .Up
                }

            case .Right:
                if labMap[curPos.x][curPos.y + RIGHT.y] != '#' {
                    curPos += RIGHT
                    if !seenLocs[curPos] {
                        total1 += 1
                        seenLocs[curPos] = true
                    }
                } else {
                    usedLocs[curPos + RIGHT] = true
                    dir = .Down
                }
        }
    }
    fmt.println("Part 1 answer:", total1) // 5534

    total2: int
    placeObj: int2
    guardPos := guardLoc(&labMap)
    usedLocs[guardPos] = true

    // This takes ~20 seconds to complete
    for str, x in labMap {
        for r, y in str {
            placeObj = {x, y}
            if !usedLocs[placeObj] {
                if testForLoop(&labMap, &seenLocs, guardPos, placeObj) {
                    total2 += 1
                    // fmt.println(total2)
                }
                usedLocs[{x, y}] = true
            }
        }
    }
    fmt.println("Part 2 answer:", total2) // 2262
}

testForLoop :: proc(
    labMap: ^[dynamic]string,
    seenLocs: ^map[int2]bool,
    guardPos: int2,
    objectPos: int2,
) -> bool {

    LIMIT :: 100
    guardPos := guardPos
    possLoop: int
    seenLocs^ = {}
    dir: Direction = .Up
    xyRange: int2 = {len(labMap), len(labMap[0])}

    for guardPos.x > 0 &&
        guardPos.x < xyRange.x - 1 &&
        guardPos.y > 0 &&
        guardPos.y < xyRange.y - 1 {

        switch dir {

            case .Up:
                if labMap[guardPos.x + UP.x][guardPos.y] != '#' &&
                   guardPos + UP != objectPos {
                    if !seenLocs[guardPos] {
                        seenLocs[guardPos] = true
                        possLoop = 0
                    } else {
                        possLoop += 1
                    }
                    if possLoop > LIMIT {
                        return true
                    }
                    guardPos += UP
                } else {
                    dir = .Right
                }

            case .Down:
                if labMap[guardPos.x + DOWN.x][guardPos.y] != '#' &&
                   guardPos + DOWN != objectPos {
                    if !seenLocs[guardPos] {
                        seenLocs[guardPos] = true
                        possLoop = 0
                    } else {
                        possLoop += 1
                    }
                    if possLoop > LIMIT {
                        return true
                    }
                    guardPos += DOWN
                } else {
                    dir = .Left
                }

            case .Left:
                if labMap[guardPos.x][guardPos.y + LEFT.y] != '#' &&
                   guardPos + LEFT != objectPos {
                    if !seenLocs[guardPos] {
                        seenLocs[guardPos] = true
                        possLoop = 0
                    } else {
                        possLoop += 1
                    }
                    if possLoop > LIMIT {
                        return true
                    }
                    guardPos += LEFT
                } else {
                    dir = .Up
                }

            case .Right:
                if labMap[guardPos.x][guardPos.y + RIGHT.y] != '#' &&
                   guardPos + RIGHT != objectPos {
                    if !seenLocs[guardPos] {
                        seenLocs[guardPos] = true
                        possLoop = 0
                    } else {
                        possLoop += 1
                    }
                    if possLoop > LIMIT {
                        return true
                    }
                    guardPos += RIGHT
                } else {
                    dir = .Down
                }
        }
    }
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
