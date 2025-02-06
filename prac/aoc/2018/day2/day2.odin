package day2
import "core:os"
import "core:fmt"
import "core:slice"
import "core:strings"

main :: proc() {
    buff, ok := os.read_entire_file("../inputs/input2.txt")
    if !ok {
        fmt.eprintln("Error. Unable to read file.")
        return
    }
    it := string(buff)
    box_ids := make([dynamic] string)
    for line in strings.split_lines_iterator(&it) {
        append(&box_ids, line)
    }
    
    
}