package day4_2024
import "core:fmt"
import "core:os"
import "core:strings"

main :: proc() {
    input: [dynamic]string
    file, ok := os.read_entire_file("input")
    checkOk(ok)
    defer {
        delete(file)
        delete(input)
    }

    str_file := string(file)
    for line in strings.split_lines_iterator(&str_file) {
        append(&input, line)
    }

    total: int
    for str, i in input {

        if i > len(input) - 4 {
            // horizontal
            for j in 0 ..< len(str) - 3 {
                testBuf := str[j:j + 4]
                if isXMAS(testBuf) {
                    total += 1
                }
            }
            // diagonal up
            for j in 0 ..< len(str) - 3 {
                sbBuf := strings.builder_make(context.temp_allocator)
                fmt.sbprint(&sbBuf, rune(str[j]))
                fmt.sbprint(&sbBuf, rune(input[i - 1][j + 1]))
                fmt.sbprint(&sbBuf, rune(input[i - 2][j + 2]))
                fmt.sbprint(&sbBuf, rune(input[i - 3][j + 3]))
                testBuf := strings.to_string(sbBuf)
                if isXMAS(testBuf) {
                    total += 1
                }
            }
            free_all(context.temp_allocator)
        } else {
            // horizontal
            for j in 0 ..< len(str) - 3 {
                testBuf := str[j:j + 4]
                if isXMAS(testBuf) {
                    total += 1
                }
            }
            // vertical
            for j in 0 ..< len(str) {
                sbBuf := strings.builder_make(context.temp_allocator)
                fmt.sbprint(&sbBuf, rune(str[j]))
                fmt.sbprint(&sbBuf, rune(input[i + 1][j]))
                fmt.sbprint(&sbBuf, rune(input[i + 2][j]))
                fmt.sbprint(&sbBuf, rune(input[i + 3][j]))
                testBuf := strings.to_string(sbBuf)
                if isXMAS(testBuf) {
                    total += 1
                }
            }
            // diagonal down
            for j in 0 ..< len(str) - 3 {
                sbBuf := strings.builder_make(context.temp_allocator)
                fmt.sbprint(&sbBuf, rune(str[j]))
                fmt.sbprint(&sbBuf, rune(input[i + 1][j + 1]))
                fmt.sbprint(&sbBuf, rune(input[i + 2][j + 2]))
                fmt.sbprint(&sbBuf, rune(input[i + 3][j + 3]))
                testBuf := strings.to_string(sbBuf)
                if isXMAS(testBuf) {
                    total += 1
                }
            }
            // diagonal up
            if i > 2 {
                for j in 0 ..< len(str) - 3 {
                    sbBuf := strings.builder_make(context.temp_allocator)
                    fmt.sbprint(&sbBuf, rune(str[j]))
                    fmt.sbprint(&sbBuf, rune(input[i - 1][j + 1]))
                    fmt.sbprint(&sbBuf, rune(input[i - 2][j + 2]))
                    fmt.sbprint(&sbBuf, rune(input[i - 3][j + 3]))
                    testBuf := strings.to_string(sbBuf)
                    if isXMAS(testBuf) {
                        total += 1
                    }
                }
            }
            free_all(context.temp_allocator)
        }
    }
    fmt.println("Part 1 answer:", total) // 2578

    total = 0
    for i := 1; i < len(input) - 1; i += 1 {

        line := input[i]

        for j := 1; j < len(line) - 1; j += 1 {
            sbBuf1 := strings.builder_make(context.temp_allocator)
            fmt.sbprint(&sbBuf1, rune(input[i - 1][j - 1])) // up and to the left
            fmt.sbprint(&sbBuf1, rune(line[j])) // middle
            fmt.sbprint(&sbBuf1, rune(input[i + 1][j + 1])) // down and to the right

            sbBuf2 := strings.builder_make(context.temp_allocator)
            fmt.sbprint(&sbBuf2, rune(input[i - 1][j + 1])) // up and to the right
            fmt.sbprint(&sbBuf2, rune(line[j])) // middle
            fmt.sbprint(&sbBuf2, rune(input[i + 1][j - 1])) // down and to the left

            testBuf1 := strings.to_string(sbBuf1)
            testBuf2 := strings.to_string(sbBuf2)

            if isX_MAS(testBuf1, testBuf2) {
                total += 1
            }
        }
        free_all(context.temp_allocator)
    }
    fmt.println("Part 2 answer:", total) // 1972
}
isXMAS :: proc(s: string) -> bool {
    if s == "XMAS" || s == "SAMX" {
        return true
    }
    return false
}
isX_MAS :: proc(s1: string, s2: string) -> bool {
    if (s1 == "MAS" || s1 == "SAM") && (s2 == "MAS" || s2 == "SAM") {
        return true
    }
    return false
}
checkOk :: proc(ok: bool) {
    if !ok {
        panic("Error")
    }
}
