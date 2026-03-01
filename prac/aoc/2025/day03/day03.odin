package day3_2025

import "core:fmt"
import "core:os"
import "core:strconv"
import "core:strings"

main :: proc() {
    file, err := os.read_entire_file_from_path("input", context.allocator)
    check_err(err)
    strFile := string(file)
    Banks := strings.split_lines(strFile)

    defer {
        delete(file)
        delete(Banks)
        free_all(context.temp_allocator)
    }

    total_jolts: int
    for bank in Banks {
        hightest_jolt: int
        for i in 0 ..< len(bank) {
            n1, ok := strconv.parse_int(bank[i:i + 1])
            checkOk(ok)
            for j := i + 1; j < len(bank); j += 1 {
                n2, ok := strconv.parse_int(bank[j:j + 1])
                checkOk(ok)
                n := n1 * 10 + n2
                if hightest_jolt < n {
                    hightest_jolt = n
                }
            }
        }
        total_jolts += hightest_jolt
    }
    fmt.println("Part 1 answer:", total_jolts)

    total_jolts = 0
    multiplier := 100000000000
    for bank in Banks {
        total_jolts += findJolts(bank, 0, len(bank) - 12, multiplier)
    }
    fmt.println("Part 2 answer:", total_jolts)
}
findJolts :: proc(bank: string, start: int, end: int, mul: int) -> int {
    n: string
    n1, n2: u8
    new_start: int

    for i := start; i <= end; i += 1 {
        n1 = bank[i]
        if n1 > n2 {
            n2 = n1
            new_start = i + 1
            n = bank[i:new_start]
        }
    }

    if n == "" {
        return 0
    }

    N, ok := strconv.parse_int(n)
    checkOk(ok)
    if mul == 1 {
        return N
    }
    N = N * mul
    mul := mul / 10
    return N + findJolts(bank, new_start, end + 1, mul)
}
checkOk :: proc(ok: bool, loc := #caller_location) {
    if !ok {
        panic("Somthing's not ok", loc)
    }
}
check_err :: proc(err: os.Error, loc := #caller_location) {
    if err != nil {
        fmt.println("error:", err)
        panic("", loc)
    }
}
