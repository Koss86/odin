package day6_2025

import "core:fmt"
import "core:strconv"

p2 :: proc(file: ^[]u8) {
    math_probs: [dynamic][dynamic]u8
    byte_buf := make([dynamic]u8, context.temp_allocator)
    for byte in file {
        if byte != '\n' {
            append(&byte_buf, byte)
        } else {
            append(&math_probs, byte_buf)
            delete(byte_buf)
            byte_buf = make([dynamic]u8, context.temp_allocator)
        }
    }

    defer {
        for array in math_probs {
            delete(array)
        }
        delete(byte_buf)
        delete(math_probs)
        free_all(context.temp_allocator)
    }

    total: int
    numbers := make([dynamic]int, context.temp_allocator)
    op_row_indx := len(math_probs) - 1
    op_row_leng := len(math_probs[op_row_indx])

    for i := len(math_probs[0]) - 1; i >= 0; i -= 1 {
        buf: [4]u8
        indx: int
        for j in 0 ..< len(math_probs) - 1 {
            byte := math_probs[j][i]
            if byte != ' ' {
                buf[indx] = byte
                indx += 1
            }
        }
        // Skip space between problems
        if buf == {} {
            continue
        }

        num_str := string(buf[:indx])
        num, ok := strconv.parse_int(num_str)
        check_ok(ok)
        append(&numbers, num)

        if i < op_row_leng {
            op := string(math_probs[op_row_indx][i:i + 1])
            if op == "+" || op == "*" {
                total += returnSum(op, numbers)
                delete(numbers)
                numbers = make([dynamic]int, context.temp_allocator)
            }
        }
    }
    fmt.println("Part 2 answer:", total)
}
