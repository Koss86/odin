package day2

import "core:os"
import "core:fmt"
import "core:strconv"
import "core:strings"

LENG :: 121
NUM :: 100

main :: proc() {
    test: bool = false
    buff: []byte
    ok: bool
    if !test {
        buff, ok = os.read_entire_file("../inputs/input2.txt", context.allocator)
    } else {
        buff, ok = os.read_entire_file("test.txt", context.allocator)
    }
    if !ok {
        fmt.eprintf("Error. Unable to read file.\n")
        return
    }
    input_tmp := string(buff)
    input := strings.clone(input_tmp, context.allocator)
    delete(buff, context.allocator)
    intcode1 := make([dynamic] int, context.allocator)
    intcode2 := make([dynamic] int, context.allocator)
    intcode0 := make([dynamic] int, context.allocator)
    for str in strings.split_after_iterator(&input, ",") {
        tmp := strconv.atoi(str)
        append(&intcode1, tmp)
        append(&intcode2, tmp)
        append(&intcode0, tmp)
    }
    intcode1[1] = 12
    intcode1[2] = 2
    for i: int; i < LENG-4; i += 4 {
        code := intcode1[i]
        val_pos := intcode1[i+1]
        val1 := intcode1[val_pos]
        val_pos = intcode1[i+2]
        val2 := intcode1[val_pos]
        val_pos = intcode1[i+3]
        if code == 1 {
            intcode1[val_pos] = val1+val2
        } else if code == 2 {
            intcode1[val_pos] = val1*val2
        } else if code == 99 {
            break
        } else {
            fmt.printfln("::Error::")
            return
        }
    }
    fmt.printfln("Part 1 answer: %v", intcode1[0])
    free(&intcode1, context.allocator)
    add1, add2: int
    exit: for x in 0..<NUM {
        intcode2[1] = add1
        add2 = 0
        reset: for y in 0..<NUM {
            intcode2[2] = add2
            for i: int; i < LENG-4; i += 4 {
                code := intcode2[i]
                val_pos := intcode2[i+1]
                val1 := intcode2[val_pos]
                val_pos = intcode2[i+2]
                val2 := intcode2[val_pos]
                val_pos = intcode2[i+3]
                if code == 1 {
                    intcode2[val_pos] = val1+val2
                } else if code == 2 {
                    intcode2[val_pos] = val1*val2
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
                for i in 0..<LENG {
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
    fmt.printfln("Part 2 answer: %v", 100*intcode2[1]+intcode2[2])
}