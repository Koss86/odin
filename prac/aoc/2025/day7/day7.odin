package day7_2025

import "core:fmt"
import "core:os"

LEFT :: -1
RIGHT :: 1

main :: proc() {
    file, ok := os.read_entire_file("input")
    check_ok(ok)
    input_grid: [dynamic][dynamic]u8
    buf: [dynamic]u8
    for r in file {
        if r != '\n' {
            append(&buf, r)
        } else {
            append(&input_grid, buf)
            buf = {}
        }
    }
    delete(buf)
    splitters_pos: [dynamic][dynamic]int
    for row, y in input_grid {
        buf := make([dynamic]int, context.temp_allocator)
        for r, x in row {
            if r == '^' {
                append(&buf, x)
            }
        }
        if len(buf) == 0 {
            delete(buf)
            continue
        }
        append(&splitters_pos, buf)
        delete(buf)
    }

    beam_start: int
    for i in 0 ..< len(input_grid[0]) {
        r := input_grid[0][i]
        if r == 'S' {
            beam_start = i
            break
        }
    }
    beam_above: map[int]bool
    beams_in_pos: map[int]int
    beam_above[beam_start] = true
    beams_in_pos[beam_start] = 1
    splits: int
    timelines: int

    for line in splitters_pos {
        for splitter in line {
            if beam_above[splitter] {
                if !beam_above[splitter + LEFT] {
                    beam_above[splitter + LEFT] = true
                    // Since there was no beam above position splitter + LEFT,
                    // set the number of beams equal to beams a position splitter
                    beams_in_pos[splitter + LEFT] = beams_in_pos[splitter]
                } else {
                    // If beams were above, combine beams at position splitter
                    // with position splitter + LEFT
                    beams_in_pos[splitter + LEFT] += beams_in_pos[splitter]
                }
                if !beam_above[splitter + RIGHT] {
                    beam_above[splitter + RIGHT] = true
                    beams_in_pos[splitter + RIGHT] = beams_in_pos[splitter]
                } else {
                    beams_in_pos[splitter + RIGHT] += beams_in_pos[splitter]
                }
                splits += 1
                beam_above[splitter] = false
                beams_in_pos[splitter] = 0
            }
        }
    }
    for key, value in beams_in_pos {
        timelines += value
    }
    fmt.println("Part 1 answer:", splits)
    fmt.println("Part 2 answer:", timelines)

    for line in input_grid {
        delete(line)
    }
    delete(file)
    delete(input_grid)
    delete(beam_above)
    delete(beams_in_pos)
    delete(splitters_pos)
    free_all(context.temp_allocator)
}
check_ok :: proc(ok: bool, loc := #caller_location) {
    if !ok {
        panic("Somthing's not ok.", loc)
    }
}
