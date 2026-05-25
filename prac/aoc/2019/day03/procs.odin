package day03_2019

import f "core:fmt"
import "core:os"
import sc "core:strconv"
import s "core:strings"

Vec2 :: [2]int

GRID_SIZE :: 1000
ORIGIN: Vec2 : {0, 0}
UP: Vec2 : {0, 1}
DOWN: Vec2 : {0, -1}
LEFT: Vec2 : {-1, 0}
RIGHT: Vec2 : {1, 0}

Wire_Path :: struct {
    dir: Vec2,
    rng: int,
}

Wires :: struct {
    wire_1: []Wire_Path,
    wire_2: []Wire_Path,
}

parse_input_into_wires :: proc(file: ^[]u8) -> (wires: Wires) {

    wire_two: bool
    wire_1: [dynamic]Wire_Path
    wire_2: [dynamic]Wire_Path
    input := string(file^)

    for line in s.split_lines_iterator(&input) {
        line := line
        for str in s.split_iterator(&line, ",") {

            tmp, ok := sc.parse_int(str[1:])
            check_ok(ok)
            buf: Wire_Path
            buf.rng = tmp

            switch str[0] {
                case 'U':
                    buf.dir = UP
                case 'D':
                    buf.dir = DOWN
                case 'L':
                    buf.dir = LEFT
                case 'R':
                    buf.dir = RIGHT
            }

            if !wire_two {
                append(&wire_1, buf)
            } else {
                append(&wire_2, buf)
            }
        }
        wire_two = true
    }

    wires.wire_1 = wire_1[:]
    wires.wire_2 = wire_2[:]

    return wires
}

// Create a list of each wire's path coordinates.
wire_paths :: proc(wires: ^Wires) -> [][]Vec2 {

    pos := ORIGIN
    path: [dynamic]Vec2

    for v in wires.wire_1 {
        for _ in 0 ..< v.rng {
            pos += v.dir
            append(&path, pos)
        }
    }

    wire_paths: [dynamic][]Vec2
    append(&wire_paths, path[:]) // wire_1

    pos = ORIGIN
    path = make([dynamic]Vec2)

    for v in wires.wire_2 {
        for _ in 0 ..< v.rng {
            pos += v.dir
            append(&path, pos)
        }
    }

    append(&wire_paths, path[:]) // wire_2

    return wire_paths[:]
}

// Find the closest intersection to `ORIGIN` by first mapping `wire_1` in `path_map`,
// then compare intersection distance of every match from `wire_2` thats found in `path_map`.
// Saving intersection positions to `intersecs` for part 2.
closest_intersec :: proc(paths: [][]Vec2, intersecs: ^[dynamic]Vec2) -> int {

    wire_1 := paths[0]
    wire_2 := paths[1]
    path_map: map[Vec2]bool

    for v in wire_1 {
        path_map[v] = true
    }

    closest := distance(ORIGIN, {GRID_SIZE, GRID_SIZE})

    for v in wire_2 {
        if path_map[v] {
            cur := distance(ORIGIN, v)
            if cur < closest {
                closest = cur
            }
            append(intersecs, v)
        }
    }

    delete(path_map)
    return closest
}

distance :: proc(a: Vec2, b: Vec2) -> int {
    return abs(a.x - b.x) + abs(a.y - b.y)
}

// Count the number of steps it takes to reach an intersection for each wire.
// Then find the intersection with the lowest combination of steps from each wire.
least_steps :: proc(paths: ^[][]Vec2, intersecs: []Vec2) -> int {

    Step :: struct {
        steps: int,
        pos:   Vec2,
    }

    xings: map[Vec2]bool
    for v in intersecs {
        xings[v] = true
    }

    s_buf: Step
    s1, s2: int
    steps_1, steps_2: [dynamic]Step

    for v in paths[0] {
        s1 += 1
        if xings[v] {
            s_buf.pos = v
            s_buf.steps = s1
            append(&steps_1, s_buf)
        }
    }

    for v in paths[1] {
        s2 += 1
        if xings[v] {
            s_buf.pos = v
            s_buf.steps = s2
            append(&steps_2, s_buf)
        }
    }

    shortest := steps_1[len(steps_1) - 1].steps + steps_2[len(steps_2) - 1].steps

    for v1 in steps_1 {
        for v2 in steps_2 {
            if v1.pos == v2.pos {
                if v1.steps + v2.steps < shortest {
                    shortest = v1.steps + v2.steps
                }
            }
        }
    }

    delete(xings)
    delete(steps_1)
    delete(steps_2)
    return shortest
}

check_ok :: proc(ok: bool, loc := #caller_location) {
    if !ok do panic("Something's not ok", loc)
}

check_err :: proc(err: os.Error, loc := #caller_location) {
    if err != nil {
        f.printfln("Error: %v - %v", err, loc)
        os.exit(1)
    }
}
