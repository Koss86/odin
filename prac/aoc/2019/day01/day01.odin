package day01_2019

import "core:fmt"
import "core:os"
import "core:strconv"
import "core:strings"

SIZE :: 100

main :: proc() {

    buff, err := os.read_entire_file("input", context.temp_allocator)
    check_err(err)
    input := string(buff)
    numbers := make([]int, SIZE, context.allocator)
    indx: int
    total: int
    for line in strings.split_lines_iterator(&input) {
        ok: bool
        tmp := line[:]
        numbers[indx], ok = strconv.parse_int(tmp)
        check_ok(ok)
        total += (numbers[indx] / 3) - 2
        indx += 1
    }

    free_all(context.temp_allocator)
    fmt.printfln("Part 1 answer: %v", total)

    total = 0
    for i in 0 ..< SIZE {
        fuel := (numbers[i] / 3) - 2
        for fuel > 0 {
            total += fuel
            fuel = (fuel / 3) - 2
        }
    }
    fmt.printfln("Part 2 answer: %v", total)
}

check_ok :: proc(ok: bool, loc := #caller_location) {
    if !ok do panic("Something's not ok", loc)
}

check_err :: proc(err: os.Error, loc := #caller_location) {
    if err != nil {
        fmt.printfln("Error: %v - %v", err, loc)
        os.exit(1)
    }
}
