package day08_2023

import f "core:fmt"
import "core:os"

main :: proc() {
    file, err := os.read_entire_file("input", context.allocator)
    // file, err := os.read_entire_file("example1", context.allocator)
    // file, err := os.read_entire_file("example2", context.allocator)
    check_err(err)

    _map := parse_input(&file)

    // example1 will not work on part 2 & example2 won't work on part 1.
    // This is the only reason for the length checks below.
    // The full input should work with both.

    if len(_map.directions) > 2 {
        moves := from_AAA_to_ZZZ(_map)
        f.println("Part 1 answer:", moves)
    }

    if len(_map.directions) != 3 {
        starts := list_ends_in_A(_map)
        loop_list := loop_counter(_map, starts)
        moves := process_loops_lengths(loop_list)
        f.println("Part 2 answer:", moves)
    }
}
