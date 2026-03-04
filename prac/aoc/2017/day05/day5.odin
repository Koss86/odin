package day5_2017

import "core:fmt"
import "core:os"
import "core:strconv"
import "core:strings"

main :: proc() {
    context.allocator = context.temp_allocator
    file, ok := os.read_entire_file("input")
    checkOk(ok)
    list1 := make([dynamic]int)
    strFile := string(file)
    for line in strings.split_lines_iterator(&strFile) {
        numBuf, ok := strconv.parse_int(line)
        checkOk(ok)
        append(&list1, numBuf)
    }

    list2 := make([dynamic]int, len(list1), cap(list1))
    copy(list2[:], list1[:])
    defer free_all(context.temp_allocator)

    curPos: int
    moves: int
    for curPos < len(list1) {
        tmp := list1[curPos]
        list1[curPos] += 1
        curPos += tmp
        moves += 1
    }

    fmt.println("Part 1 answer:", moves) // 388611

    curPos = 0
    moves = 0
    for curPos < len(list2) {
        tmp := list2[curPos]
        if tmp > 2 {
            list2[curPos] -= 1
        } else {
            list2[curPos] += 1
        }
        curPos += tmp
        moves += 1
    }
    fmt.println("Part 2 answer:", moves) // 27763113

}
checkOk :: proc(ok: bool) {
    if !ok {
        panic("Somthing's not ok.")
    }
}
