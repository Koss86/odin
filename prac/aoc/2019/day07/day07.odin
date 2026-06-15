package day07_2019

import f "core:fmt"
import "core:os"

main :: proc() {

    run_examples()
    input, err := os.read_entire_file("input", context.allocator)
    intcode := parse_file(input)

    f.println("Part 1 answer:", configure_amp(intcode))
    f.println("Part 2 answer:", configure_with_feedback(intcode))
}
