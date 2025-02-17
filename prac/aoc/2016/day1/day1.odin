package day1
import "core:os"
import "core:fmt"
import "core:strconv"
import "core:strings"

Vec2 :: [2]int
ORIGIN :: Vec2 { 0, 0 }
Right :: Vec2 { 1, 0 }
Left :: Vec2 { -1, 0 }
Up :: Vec2 { 0, 1 }
Down :: Vec2 { 0, -1 }
ORG_DIR :: Up

main :: proc() {
    buff, ok := os.read_entire_file("../inputs/input1.txt", context.allocator)
    if !ok {
        fmt.eprintln("Error. Unable to open file.")
        return
    }
    defer delete(buff, context.allocator)
    input := string(buff)
    pos: Vec2
    ct: int
    dis2: int
    cur_dir: Vec2 = ORG_DIR
    seen_vectors := make(map[Vec2]int, context.allocator)
    for str in strings.split_iterator(&input, ",") {
        tmp_str := strings.trim_space(str)
        turn := tmp_str[0]
        cur_dir = next_dir(cur_dir, turn)
        amt := strconv.atoi(tmp_str[1:])
        for _ in 0..<amt {
            pos += cur_dir
            seen_vectors[pos] += 1
            if seen_vectors[pos] > 1 && ct < 1 {
                dis2 = manhattan_distance(ORIGIN, pos)
                ct += 1
            }
        }
    }
    dis1 := manhattan_distance(ORIGIN, pos)
    fmt.printfln("Part 1 answer: %v", dis1)
    fmt.printfln("Part 2 answer: %v", dis2)
}

next_dir :: proc(dir: Vec2, turn: u8) -> Vec2 {
    dir := dir
    if turn == 'L' {
        if dir == Up {
            dir = Left
        } else if dir == Down {
            dir = Right
        } else if dir == Left {
            dir = Down
        } else {
            dir = Up
        }
    } else {
        if dir == Up {
            dir = Right
        } else if dir == Down {
            dir = Left 
        } else if dir == Left {
            dir = Up
        } else {
            dir = Down
        }
    }
    return dir
}
manhattan_distance :: proc(a: Vec2, b: Vec2) -> int {
    return abs(a.x - b.x) + abs(a.y - b.y)
}