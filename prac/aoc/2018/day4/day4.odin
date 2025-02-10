package day4

import "core:os"
import "core:fmt"
import "core:strconv"
import "core:strings"

Schedule :: struct {
    year: int,
    month: int,
    day: int,
    hour: int,
    min: int
}


main :: proc() {
    buff, ok := os.read_entire_file("../inputs/input4.txt", context.temp_allocator)
    if !ok {
        fmt.eprintfln("Error. Unable to read file.")
        return
    }
    input := string(buff)
    for line in strings.split_lines_iterator(&input) {
        split := line
        splits := [?]string {"-"," ",":"}
    }

    schedule_map :=  make(map[int]int, context.temp_allocator) // prolly needs changing :)
}