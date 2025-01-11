package aoc_2024_day3

import "core:os"
import "core:fmt"
import "core:slice"
import "core:strings"
import "core:strconv"
import "core:text/scanner"



main :: proc() {


    file := "input.txt"
    buff, ok := os.read_entire_file(file, context.allocator)
    if !ok {
        fmt.eprintln("Error. Unable to open file.")
        return
    }


}