package day3
import "core:os"
import "core:fmt"
import "core:strconv"
import "core:strings"

SIZE :: 301
GRID_SIZE :: 1000
ORIGIN :: Vec2 { 500, 500 }

Vec2 :: [2] int
Up :: Vec2 { 0, 1 }
Down :: Vec2 { 0, -1 }
Left :: Vec2 { -1, 0 }
Right :: Vec2 { 1, 0 }
Wire_Path :: struct {
    dir: rune,
    dis: int   
}

main :: proc() {
    buff, ok := os.read_entire_file("../inputs/input3.txt", context.allocator)
    if !ok {
        fmt.eprintln("Error. Unable to read file.")
        return
    }
    input := string(buff)
    wire1 := make([] Wire_Path, SIZE, context.allocator)
    wire2 := make([] Wire_Path, SIZE, context.allocator)
    swtch: bool
    for line in strings.split_lines_iterator(&input) {
        nl := line
        i: int
        for str in strings.split_after_iterator(&nl, ",") {
            if !swtch {
                wire1[i].dir = rune(str[0])
                tmp := strconv.atoi(str[1:])
                wire1[i].dis = tmp
            } else {
                wire2[i].dir = rune(str[0])
                tmp := strconv.atoi(str[1:])
                wire2[i].dis = tmp
            }
            i += 1
        }
        swtch = true
    }
    delete(buff, context.allocator)
    wire_paths := make(map[Vec2]int, context.allocator)
    trace_wire(wire1, &wire_paths)
    trace_wire(wire2, &wire_paths)

    for x in 0..<GRID_SIZE {
        for y in 0..<GRID_SIZE {
            pos := Vec2 { x, y }
            if wire_paths[pos] > 1 {
                fmt.println(pos)
            }
        }
    }
    for x in -1000..<0 {
        for y in -1000..<0 {
            pos := Vec2 { x, y }
            if wire_paths[pos] > 1 {
                fmt.println(pos)
            }
        }
    }
}
trace_wire :: proc(wire: [] Wire_Path, paths: ^map[Vec2]int) {
    pos: Vec2 = ORIGIN
    for i in 0..<SIZE {
        if wire[i].dis > GRID_SIZE {
            fmt.eprintln("Error. ITS OVER 1000!")
            return
        }
        if wire[i].dir == 'U'{
            for _ in 0..<wire[i].dis {
                pos += Up
                paths[pos] += 1
            }
        } else if wire[i].dir == 'D' {
            for _ in 0..<wire[i].dis {
                pos += Down
                paths[pos] += 1
            } 
        } else if wire[i].dir == 'L' {
            for _ in 0..<wire[i].dis {
                pos += Left
                paths[pos] += 1
            }
        } else if wire[i].dir == 'R' {
            for _ in 0..<wire[i].dis {
                pos += Right
                paths[pos] += 1
            }
        }
    }
}
