package day09_2019

import f "core:fmt"
import "core:os"

main :: proc() {

    file, err := os.read_entire_file("input", context.allocator)
    check_err(err)

    boost := parse_file(file)
    delete(file)

    run_examples()

    f.printf("Part 1 answer: ")
    intcode_computer(&boost, 1)

    f.printf("Part 2 answer: ")
    intcode_computer(&boost, 2)
}
