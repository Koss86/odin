package day02_2019

import "core:fmt"
import "core:os"
import "core:strconv"
import "core:strings"

LENG :: 121
NUM :: 100

main :: proc() {

    buff, err := os.read_entire_file("input", context.allocator)
    check_err(err)

    input_tmp := string(buff)
    input := strings.clone(input_tmp, context.allocator)
    delete(buff, context.allocator)
    intcode1 := make([dynamic]int, context.allocator)
    intcode2 := make([dynamic]int, context.allocator)
    intcode0 := make([dynamic]int, context.allocator)

    for str in strings.split_iterator(&input, ",") {
        str := str
        if strings.contains(str, "\n") {
            str = strings.trim(str, "\n")
        }
        tmp, ok := strconv.parse_int(str)
        check_ok(ok)
        append(&intcode1, tmp)
        append(&intcode2, tmp)
        append(&intcode0, tmp)
    }

    intcode1[1] = 12
    intcode1[2] = 2

    for i: int; i < LENG - 4; i += 4 {
        code := intcode1[i]
        val_pos := intcode1[i + 1]
        val1 := intcode1[val_pos]
        val_pos = intcode1[i + 2]
        val2 := intcode1[val_pos]
        val_pos = intcode1[i + 3]
        if code == 1 {
            intcode1[val_pos] = val1 + val2
        } else if code == 2 {
            intcode1[val_pos] = val1 * val2
        } else if code == 99 {
            break
        } else {
            fmt.printfln("::Error::")
            return
        }
    }

    fmt.println("Part 1 answer:", intcode1[0])

    add1, add2: int
    exit: for x in 0 ..< NUM {
        intcode2[1] = add1
        add2 = 0
        for y in 0 ..< NUM {
            intcode2[2] = add2
            for i: int; i < LENG - 4; i += 4 {
                code := intcode2[i]
                val_pos := intcode2[i + 1]
                val1 := intcode2[val_pos]
                val_pos = intcode2[i + 2]
                val2 := intcode2[val_pos]
                val_pos = intcode2[i + 3]
                if code == 1 {
                    intcode2[val_pos] = val1 + val2
                } else if code == 2 {
                    intcode2[val_pos] = val1 * val2
                } else if code == 99 {
                    break
                } else {
                    fmt.printfln("::Error::")
                    return
                }
            }
            if intcode2[0] == 19690720 {
                break exit
            } else {
                for i in 0 ..< LENG {
                    if i == 1 {
                        continue
                    }
                    intcode2[i] = intcode0[i]
                }
            }
            add2 += 1
        }
        add1 += 1
    }
    fmt.println("Part 2 answer:", 100 * intcode2[1] + intcode2[2])
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
