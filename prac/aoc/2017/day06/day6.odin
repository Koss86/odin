package day6_2017

import "core:fmt"
import "core:os"
import "core:strconv"
import "core:strings"

BANK_SIZE :: 16

main :: proc() {
    file, ok := os.read_entire_file("input")
    checkOk(ok)
    fileStr := string(file)
    indx: int
    memBank: [BANK_SIZE]int
    // Input needs to end in a tab '\t' or
    // the last element will not be read
    for str in strings.split_iterator(&fileStr, "\t") {
        buf, ok := strconv.parse_int(str)
        if ok && indx < BANK_SIZE {
            memBank[indx] = buf
            indx += 1
        }
    }

    seenLayouts := make(map[[BANK_SIZE]int]bool)
    cycles: int
    for !seenLayouts[memBank] {
        cycles += 1
        seenLayouts[memBank] = true
        topIndx := highNumIndx(&memBank)
        topNum := memBank[topIndx]
        memBank[topIndx] = 0
        for i := topNum; i > 0; i -= 1 {
            topIndx += 1
            if topIndx > BANK_SIZE - 1 {
                topIndx = 0
            }
            memBank[topIndx] += 1
        }
    }
    fmt.println("Part 1 answer:", cycles) // 4074

    loopState := memBank
    cycles = 0
    for {
        topIndx := highNumIndx(&memBank)
        topNum := memBank[topIndx]
        memBank[topIndx] = 0
        for i := topNum; i > 0; i -= 1 {
            topIndx += 1
            if topIndx > BANK_SIZE - 1 {
                topIndx = 0
            }
            memBank[topIndx] += 1
        }
        cycles += 1

        if memBank == loopState {
            break
        }
    }
    fmt.println("Part 2 answer:", cycles) // 2793
}
highNumIndx :: proc(memBank: ^[BANK_SIZE]int) -> int {
    indx: int
    n: int
    for v, i in memBank {
        if v > n {
            n = v
            indx = i
        }
    }
    return indx
}
checkOk :: proc(ok: bool, loc := #caller_location) {
    if !ok {
        panic("Somthing's not ok.", loc)
    }
}
