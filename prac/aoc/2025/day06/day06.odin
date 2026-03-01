package day6_2025

import "core:fmt"
import "core:os"
import "core:strconv"
import "core:strings"

main :: proc() {
    file, err := os.read_entire_file_from_path("input", context.allocator)
    check_err(err)
    str_file := string(file)
    buf: [dynamic]string
    math_probs: [dynamic][dynamic]string

    defer {
        for str in math_probs {
            delete(str)
        }
        delete(math_probs)
        delete(file)
    }

    for line in strings.split_lines_iterator(&str_file) {
        line := line
        for str in strings.split_iterator(&line, " ") {
            if str == "" { continue }
            append(&buf, str)
        }
        append(&math_probs, buf)
        buf = {}
    }

    total: int
    for i in 0 ..< len(math_probs[0]) {
        numbers := make([dynamic]int, context.temp_allocator)
        for j in 0 ..< len(math_probs) - 1 {
            num, ok := strconv.parse_int(math_probs[j][i])
            check_ok(ok)
            append(&numbers, num)
        }
        op := math_probs[len(math_probs) - 1][i]
        total += returnSum(op, numbers)
        free_all(context.temp_allocator)
    }
    fmt.println("Part 1 answer:", total)
    p2(&file)
}
returnSum :: proc(operator: string, numbers: [dynamic]int) -> int {
    sum: int
    switch operator {
        case "+":
            for n in numbers {
                sum += n
            }
        case "*":
            sum = numbers[0]
            for i := 1; i < len(numbers); i += 1 {
                if numbers[i] == 0 { continue }
                sum = sum * numbers[i]
            }
    }
    return sum
}
check_err :: proc(err: os.Error, loc := #caller_location) {
    if err != nil {
        fmt.println("error:", err)
        panic("", loc)
    }
}
check_ok :: proc(ok: bool, loc := #caller_location) {
    if !ok {
        panic("Somthing's not ok.", loc)
    }
}
