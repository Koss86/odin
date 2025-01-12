package test

import "core:fmt"
import "core:os"
import "core:strings"
import "core:unicode"
import "core:unicode/utf8"

main :: proc() {
    file:= "../input.txt"
    data, ok := os.read_entire_file(file, context.allocator)
    if !ok {
        fmt.eprintfln("Error. Unable to open file.")
        return
    }
    defer delete(data, context.allocator)

    it1 := string(data)

    for line in strings.split_lines_iterator(&it1) {
        for i in 0..<len(line) {
            if line[i] == 'm' {
                fmt.printfln("%r", line[i])
            }
        }
    }
     
}
