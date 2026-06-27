package day11_2019

import "core:os"

main :: proc() {
    file, err := os.read_entire_file("input", context.allocator)
    check_err(err)
    intcode0 := parse_file(file)
    intcode1 := parse_file(file)
    paint_hull(&intcode0, 0)
    paint_hull(&intcode1, 1)
}
