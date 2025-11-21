package day3_2017

import "core:fmt"

Bounds :: struct {
    xMax: int,
    xMin: int,
    yMax: int,
    yMin: int,
}

Direction :: enum {
    Up,
    Down,
    Left,
    Right,
}

int2 :: [2]int
UP :: int2{0, 1}
DOWN :: int2{0, -1}
LEFT :: int2{-1, 0}
RIGHT :: int2{1, 0}
UP_LEFT :: int2{-1, 1}
UP_RIGHT :: int2{1, 1}
DOWN_LEFT :: int2{-1, -1}
DOWN_RIGHT :: int2{1, -1}

main :: proc() {
    context.allocator = context.temp_allocator
    memNum := 1
    curPos: int2
    bounds: Bounds
    puzzleInput := 325489
    dir: Direction = .Right

    for memNum != puzzleInput {

        switch dir {
            case .Right:
                if curPos.x < bounds.xMax {
                    // Keep moving if not at edge
                    curPos += RIGHT
                } else {
                    // If at edge - move forward, increase bounds and change direction
                    curPos += RIGHT
                    bounds.xMax += 1
                    dir = .Up
                }
            case .Up:
                if curPos.y < bounds.yMax {
                    curPos += UP
                } else {
                    curPos += UP
                    bounds.yMax += 1
                    dir = .Left
                }
            case .Left:
                if curPos.x > bounds.xMin {
                    curPos += LEFT
                } else {
                    curPos += LEFT
                    bounds.xMin -= 1
                    dir = .Down
                }
            case .Down:
                if curPos.y > bounds.yMin {
                    curPos += DOWN
                } else {
                    curPos += DOWN
                    bounds.yMin -= 1
                    dir = .Right
                }
        }
        memNum += 1
    }
    num1 := curPos.x
    num2 := curPos.y
    if curPos.x < 0 {
        num1 = curPos.x * -1
    }
    if curPos.y < 0 {
        num2 = curPos.y * -1
    }
    fmt.println("Part 1 answer:", num1 + num2) // 552

    bounds = {}
    dir = .Right
    curPos = {0, 0}
    values := make(map[int2]int)
    defer free_all(context.temp_allocator)
    values[curPos] = 1
    val: int

    for val <= puzzleInput {
        switch dir {
            case .Right:
                if curPos.x != bounds.xMax {
                    curPos += RIGHT
                } else {
                    curPos += RIGHT
                    bounds.xMax += 1
                    dir = .Up
                }
            case .Up:
                if curPos.y != bounds.yMax {
                    curPos += UP
                } else {
                    curPos += UP
                    bounds.yMax += 1
                    dir = .Left
                }
            case .Left:
                if curPos.x != bounds.xMin {
                    curPos += LEFT
                } else {
                    curPos += LEFT
                    bounds.xMin -= 1
                    dir = .Down
                }
            case .Down:
                if curPos.y != bounds.yMin {
                    curPos += DOWN
                } else {
                    curPos += DOWN
                    bounds.yMin -= 1
                    dir = .Right
                }
        }
        val = findValue(curPos, &values)
        values[curPos] = val
    }
    fmt.println("Part 2 answer:", val) // 330785
}
findValue :: proc(curPos: int2, values: ^map[int2]int) -> int {
    v: int
    v += values[curPos + UP]
    v += values[curPos + DOWN]
    v += values[curPos + LEFT]
    v += values[curPos + RIGHT]
    v += values[curPos + UP_LEFT]
    v += values[curPos + UP_RIGHT]
    v += values[curPos + DOWN_LEFT]
    v += values[curPos + DOWN_RIGHT]
    return v
}
