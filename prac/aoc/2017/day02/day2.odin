package day2

import "core:os"
import "core:fmt"
import "core:strconv"
import "core:strings"

SIZE :: 16

Spread_Sheet :: struct {
    num: [16] int
}

main :: proc() {
    buff: []byte
    ok: bool
    test: bool = false
    if test {
        buff, ok = os.read_entire_file("test.txt", context.temp_allocator)
    } else {
        buff, ok = os.read_entire_file("../inputs/input2.txt", context.temp_allocator)
    }
    if !ok {
        fmt.eprintln("Error. Unable to open file.")
        return
    }
    
    input := string(buff)
    spread_sheets := make([]Spread_Sheet, SIZE, context.allocator)
    sheetIndx: int
    
    for line in strings.split_lines_iterator(&input) {
        it := line
        split := " "
        numsIndx: int
        for str in strings.split_iterator(&it, split) {
            //tmp := strings.trim_space(str)
            num := strconv.atoi(str)
            //fmt.println(num)
            spread_sheets[sheetIndx].num[numsIndx] = num
            
            numsIndx += 1
        }
        sheetIndx += 1
    }
    free_all(context.temp_allocator)
    total: int
    for i in 0..<SIZE {
            total += high_low_diff(spread_sheets[i].num[:])
        
    }
    fmt.printfln("Part 1 answer: %v", total)  // 676784 too high.
    total = 0
    for i in 0..<SIZE {
        total += is_divisable(spread_sheets[i].num[:])
    }
    fmt.printfln("Part 2 answer: %v", total)
}
high_low_diff :: proc(nums: []int) -> int {
    h: int = nums[0]
    l: int = nums[0]
    for i in 0..<SIZE {

        if h < nums[i] {
            h = nums[i]
        }
        if l > nums[i] {
            l = nums[i]
        }
    }
    return h-l
}
is_divisable :: proc(nums: []int) -> int {
    for i in 0..<SIZE {
        n1 := nums[i]
        for j in 0..<SIZE {
            if i == j {
                continue
            }
            n2 := nums[j]
            if n1 > n2 {
                if n1%n2 == 0 {
                    return n1/n2
                }
            } else {
                if n2%n1 == 0 {
                    return n2/n1
                }
            }
        }
    }
    fmt.println("You shouldnt see this.")
    return -1
}