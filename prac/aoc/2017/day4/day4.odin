package day4_2017

import "core:fmt"
import "core:os"
import "core:strings"

main :: proc() {
    context.allocator = context.temp_allocator
    file, ok := os.read_entire_file("input")
    checkOk(ok)
    fileStr := string(file)
    bufArry := make([dynamic]string)
    passPhrases := make([dynamic][dynamic]string)
    for line in strings.split_lines_iterator(&fileStr) {
        line := line
        for str in strings.split_iterator(&line, " ") {
            append(&bufArry, str)
        }
        append(&passPhrases, bufArry)
        bufArry = {}
    }

    total: int
    valid := true
    seenStrs := make(map[string]bool)
    for phrase in passPhrases {
        for str in phrase {
            if !seenStrs[str] {
                seenStrs[str] = true
            } else {
                valid = false
            }
        }
        if valid {
            total += 1
        }
        seenStrs = {}
        valid = true
    }
    fmt.println("Part 1 answer:", total) // 451

    total = 0
    valid = true
    matched := make(map[int]bool)

    for phrase in passPhrases {

        str1Loop: for str1, i in phrase {
            for str2, j in phrase {
                if i == j {
                    continue
                }
                if len(str1) == len(str2) {
                    n1 := strSum(str1)
                    n2 := strSum(str2)
                    if n1 == n2 {
                        matched = {}
                        valid = checkSim(str1, str2, &matched)
                    }
                }
                if !valid {
                    break str1Loop
                }
            }
        }

        if valid {
            total += 1
        }
        valid = true
    }

    fmt.println("Part 2 answer:", total) // 223
    free_all(context.temp_allocator)
}
strSum :: proc(s: string) -> u8 {
    sum: u8
    for r in s {
        sum += u8(r)
    }
    return sum
}
checkSim :: proc(s1: string, s2: string, matches: ^map[int]bool) -> bool {
    matched: int
    for r1 in s1 {
        r2Loop: for r2, i in s2 {
            if r1 == r2 && !matches[i] {
                matches[i] = true
                matched += 1
                break r2Loop
            }
        }
    }
    if matched == len(s1) {
        return false
    }
    return true
}
checkOk :: proc(ok: bool) {
    if !ok {
        panic("Somthing's not ok.")
    }
}
