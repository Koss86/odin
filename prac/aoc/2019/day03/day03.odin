package day03_2019

import f "core:fmt"
import "core:os"

main :: proc() {

    file, err := os.read_entire_file("inputs/input", context.allocator)
    // file, err := os.read_entire_file("inputs/p1/example1", context.allocator)
    // file, err := os.read_entire_file("inputs/p1/example2", context.allocator)
    // file, err := os.read_entire_file("inputs/p1/example3", context.allocator)
    // file, err := os.read_entire_file("inputs/p2/example1", context.allocator)
    // file, err := os.read_entire_file("inputs/p2/example2", context.allocator)
    check_err(err)

    wires := parse_input(&file)
    paths := wire_paths(&wires)
    intersecs: [dynamic]Vec2

    f.println("Part 1 answer:", closest_intersec(paths, &intersecs))
    f.println("Part 2 answer:", least_steps(&paths, intersecs[:]))
}
