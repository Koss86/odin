package day1
import "core:os"
import "core:fmt"
import "core:strconv"
import "core:strings"

main :: proc() {
    buff, ok := os.read_entire_file("../inputs/input1.txt", context.allocator)
    if !ok {
        fmt.eprintln("Error. Unable to open file.")
        return
    }
    input := string(buff)
    floor: int
    found: bool
    indx := 1
    answer2: int
    for r in input {
        if r == '('{
            floor += 1
        } else if r == ')' {
            floor -= 1
        }
        if floor == -1 {
            if !found {
                answer2 = indx
                found = true                
            }
        }
        indx += 1
    }
    fmt.printfln("Part 1 answer: Floor %v", floor)
    fmt.printfln("Part 2 answer: %v", answer2)
}