package aoc_2024_day3

import "core:fmt"
import "core:os"
import "core:strconv"
import "core:strings"

MAX_MUL :: 12
MIN_MUL :: 8

main :: proc() {
    muls: [dynamic]string
    keepers: [dynamic]int
    data, ok := os.read_entire_file("input.txt", context.allocator)
    if !ok {
        panic("Error. Unable to open file.")
    }
    defer {
        delete(data, context.allocator)
        delete(muls)
        delete(keepers)
    }

    it := string(data)
    indx: int
    enabled := true
    for line in strings.split_lines_iterator(&it) {

        leng := len(line)
        for i in 0 ..< leng - 4 {

            if i < leng - 7 {
                doOrDont := line[i:i + 7]
                if doOrDont == "don't()" {
                    enabled = false
                    continue
                }
            }
            if i < leng - 4 {
                doOrDont := line[i:i + 4]
                if doOrDont == "do()" {
                    enabled = true
                    continue
                }
            }

            mul := line[i:i + 4]

            if mul == "mul(" {
                mul_found := false
                for j := MIN_MUL - 1; j < MAX_MUL; j += 1 {

                    if i + j >= leng || mul_found {
                        continue
                    }
                    // mul(1,1) mul(12,12) mul(100,100)
                    if line[i + j] == ')' {
                        if line[i + 5] != ',' {
                            if line[i + 6] != ',' {
                                if line[i + 7] != ',' {
                                    continue
                                }
                            }
                        }

                        mul_found = true
                        start := i + 4
                        end := i + j
                        append(&muls, line[start:end])
                        if enabled {
                            append(&keepers, indx)
                        }
                        indx += 1
                    }
                }
            }
        }
    }

    indx = 0
    one, two, total1, total2: int
    for str, i in muls {
        mul_str := str
        tmp, ok := strings.split_iterator(&mul_str, ",")
        checkOk(ok)
        one, ok = strconv.parse_int(tmp)
        checkOk(ok)

        tmp, ok = strings.split_iterator(&mul_str, ",")
        checkOk(ok)
        two, ok = strconv.parse_int(tmp)
        checkOk(ok)

        mul := one * two
        total1 += mul
        if indx < len(keepers) && i == keepers[indx] {
            total2 += mul
            indx += 1
        }
    }
    fmt.println("Part 1 answer:", total1) // 173517243
    fmt.println("Part 2 answer:", total2) // 100450138
}
checkOk :: proc(ok: bool) {
    if !ok {
        panic("Error.")
    }
}
