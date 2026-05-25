package day05_2019

import f "core:fmt"
import "core:os"
import sl "core:slice"

main :: proc() {

    // file, err := os.read_entire_file("input", context.allocator)
    file, err := os.read_entire_file("example", context.allocator)
    // file, err := os.read_entire_file("tests/eqtest1", context.allocator)
    // file, err := os.read_entire_file("tests/lttest1", context.allocator)
    // file, err := os.read_entire_file("tests/jmptest1", context.allocator)
    check_err(err)

    intcode_1 := parse_file(&file)
    intcode_2 := sl.clone(intcode_1)

    if len(intcode_1) > 50 {

        // Full input
        f.printf("Part 1 answer: ")
        test_input(&intcode_1, 1)
        f.printf("Part 2 answer: ")
        test_input(&intcode_2, 5)

    } else {

        // Example/Tests
        intcode_3 := sl.clone(intcode_1)
        test_input(&intcode_1, 0)
        test_input(&intcode_2, 8)
        test_input(&intcode_3, 9)
    }
}
