package day1

import "core:os"
import "core:fmt"
import "core:strconv"
import "core:strings"

main :: proc() {
    buff, ok := os.read_entire_file("../inputs/input1.txt", context.allocator)
    if !ok {
        fmt.eprintln("Error. Unable to read file.")
        return
    }
    input := string(buff)
    total: int = 9
    leng := len(input)
    for i in 0..<leng-1 {
        num1 := strconv.atoi(input[i:i+1])
        num2 := strconv.atoi(input[i+1:i+2])
        if num1 == num2 {
            total += num1
        }
    }
    //fmt.println(input[1081]-48)
    fmt.printfln("Part 1 answer: %v", total)
    mid := len(input)/2
    j := mid
    total = 0
    for i in 0..<leng {                         // 1181 too low.
        num1 := strconv.atoi(input[i:i+1])
        num2 := strconv.atoi(input[j:j+1])
        if num1 == num2 {
            total += num1
        }
        if j == leng-1 {
            j = 0
        } else {
            j += 1
        }
    }
    fmt.printfln("Part 2 answer: %v", total)
}