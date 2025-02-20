package day2
import "core:os"
import "core:fmt"
import "core:strconv"
import "core:strings"

WIDTH :: 3
Vec2 :: [2]int
Up :: Vec2 { 0, 1 }
Down :: Vec2 { 0, -1 }
Left :: Vec2 { 1, 0 }
Right :: Vec2 { -1, 0 }
START_POS :: Vec2 { 1, 1 }

main :: proc() {
    test := false
    buff: []byte
    ok: bool
    if test {
        buff, ok = os.read_entire_file("test.txt", context.allocator)
    } else {
        buff, ok = os.read_entire_file("../inputs/input2.txt", context.allocator)
    }
    if !ok {
        fmt.eprintfln("Error. Unable to open file")
        return
    }
    input := string(buff)
    pos := START_POS
    move_pos: Vec2
    key_pad_nums := WIDTH*WIDTH
    key_pad1: [WIDTH] [WIDTH] int
    for y in 0..<WIDTH {
        for x in 0..<WIDTH {
            key_pad1[x][y] = key_pad_nums
            key_pad_nums -= 1
        }
    }
    fmt.printf("Part 1 answer: ")
    for line in strings.split_lines_iterator(&input) {
        for r in line {
            if r == 'U' {
                move_pos = Up
            } else if r == 'D' {
                move_pos = Down
            } else if r == 'L' {
                move_pos = Left
            } else if r == 'R' {
                move_pos = Right
            }
            tmp := pos+move_pos
            if tmp.x < 0 || tmp.y >= WIDTH ||
                tmp.y < 0 || tmp.x >= WIDTH {
                    continue
            }
            pos += move_pos
        }
        fmt.printf("%v", key_pad1[pos.x][pos.y])
    }
    fmt.printf("\n")
}