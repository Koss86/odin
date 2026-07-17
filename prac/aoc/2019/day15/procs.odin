package day15_2019

import "../../util"
import f "core:fmt"

Vec2 :: [2]int

UP :: Vec2{0, -1}
DOWN :: Vec2{0, 1}
LEFT :: Vec2{-1, 0}
RIGHT :: Vec2{1, 0}

Queue :: struct {
    pos: Vec2,
    val: int,
}

map_and_find_o2 :: proc(ic: ^map[int]int) -> (map[Vec2]u8, Vec2) {

    ins: util.Instruction
    dir: []Vec2 = {UP, DOWN, LEFT, RIGHT}
    op_dir: []Vec2 = {DOWN, UP, RIGHT, LEFT}
    input: []int = {1, 2, 3, 4}
    op_input: []int = {2, 1, 4, 3}
    visited: map[Vec2]bool
    path: [dynamic]int
    area: map[Vec2]u8
    pos: Vec2

    for {

        moved: bool
        for i in 0 ..< 4 {

            nxt := pos + dir[i]
            if visited[nxt] { continue }

            visited[nxt] = true
            out := util.run_intcode(ic, &ins, input[i])

            if out == 0 {
                area[nxt] = '#'
                continue
            } else if out == 1 {
                area[nxt] = '.'
            } else {
                area[nxt] = '*'
                return area, nxt
            }

            pos = nxt
            util.push(i, &path)
            moved = true
            break
        }

        if moved { continue }
        if len(path) == 0 { panic("o2 not found") }
        last := util.pop(&path)
        util.run_intcode(ic, &ins, op_input[last])
        pos += op_dir[last]
    }
}

steps_to_o2 :: proc(area: map[Vec2]u8, goal: Vec2) -> int {
    queue: [dynamic]Queue
    append(&queue, Queue{{0, 0}, 0})
    visited: map[Vec2]bool
    dirs: []Vec2 = {UP, DOWN, LEFT, RIGHT}
    defer delete(queue)
    defer delete(visited)

    for len(queue) > 0 {
        cur := util.pop(&queue)
        for dir in dirs {
            nxt := cur.pos + dir
            if nxt == goal { return cur.val + 1 }
            if !visited[nxt] {
                visited[nxt] = true
                if area[nxt] == '.' {
                    append(&queue, Queue{nxt, cur.val + 1})
                }
            }
        }
    }
    return 0
}

time_to_fill :: proc(area: map[Vec2]u8, o2: Vec2) -> int {
    time: int
    queue: [dynamic]Queue
    append(&queue, Queue{o2, 0})
    visited: map[Vec2]bool
    dirs: []Vec2 = {UP, DOWN, LEFT, RIGHT}
    defer delete(queue)
    defer delete(visited)

    for len(queue) > 0 {
        cur := util.pop(&queue)
        for dir in dirs {
            nxt := cur.pos + dir
            if !visited[nxt] {
                if area[nxt] == '.' {
                    visited[nxt] = true
                    append(&queue, Queue{nxt, cur.val + 1})
                    if time < cur.val + 1 { time = cur.val + 1 }
                }
            }
        }
    }
    return time
}

print_maze :: proc(area: map[Vec2]u8) {
    upper, lower: Vec2
    for pos in area {
        if upper.x < pos.x { upper.x = pos.x }
        if upper.y < pos.y { upper.y = pos.y }
        if lower.x > pos.x { lower.x = pos.x }
        if lower.y > pos.y { lower.y = pos.y }
    }
    for y in lower.y ..= upper.y {
        for x in lower.x ..= upper.x {
            if x == 0 && y == 0 {
                f.printf("\e[32mS\e[m")
                continue
            }
            if area[{x, y}] == '.' {
                f.printf(".")
            } else if area[{x, y}] == '*' {
                f.printf("\e[31m*\e[m")
            } else {
                f.printf("%c", rune(9608))
            }
        }
        f.printf("\n")
    }
}
