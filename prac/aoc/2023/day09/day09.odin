package day09_2023

import f "core:fmt"
import "core:os"

main :: proc() {
    // file, err := os.read_entire_file("input", context.allocator)
    file, err := os.read_entire_file("example", context.allocator)
    check_err(err)

    oasis_history := parse_input(&file)

    total := sum_all_next_or_before(&oasis_history)
    f.println("Part 1 answer:", total)

    total = sum_all_next_or_before(&oasis_history, part1 = false)
    f.println("Part 2 answer:", total)
}
