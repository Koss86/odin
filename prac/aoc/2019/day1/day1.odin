package day1

import "core:os"
import "core:fmt"
import "core:strconv"
import "core:strings"

SIZE :: 100

main :: proc() {
    buff, ok := os.read_entire_file("../inputs/input1.txt", context.temp_allocator)
    if !ok {
        fmt.eprintln("Error. Unable to open file.")
        return
    }
    input := string(buff)
    numbers := make([]int, 100, context.allocator)
    indx: int
    total: int
    for line in strings.split_lines_iterator(&input) {
        tmp := line[:]
        numbers[indx] = strconv.atoi(tmp)
        total += (numbers[indx]/3)-2
        indx += 1
    }

    free_all(context.temp_allocator)
    fmt.printfln("Part 1 answer: %v", total)

    total = 0
    for i in 0..<SIZE {
    litmus := (numbers[i]/3)-2
        for litmus > 0 {
            total += litmus
            litmus = (litmus/3)-2
        }
    }
    fmt.printfln("Part 2 answer: %v", total)
}
