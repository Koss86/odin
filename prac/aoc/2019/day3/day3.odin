package day3
import "core:os"
import "core:fmt"
import "core:strconv"
import "core:strings"

Vec2 :: [2] int

main :: proc() {
    buff, ok := os.read_entire_file("../inputs/input3.txt")
    if !ok {
        fmt.eprintln("Error. Unable to read file.")
        return
    }
    input := string(buff)
    for line in strings.split_lines_iterator(&input) {
        nl := line
        for str in strings.split_after_iterator(&nl, ",") {
            tmp := strconv.atoi(str[1:])
            
        }
    }
}