package day2

import "core:os"
import "core:fmt"
import "core:strconv"
import "core:strings"

SIZE :: 16

Values :: struct {
    value: [4]int
}

Spread_Sheet :: struct {
    numbers: [16] Values
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
    for i in 0..<SIZE {
        for j in 0..<SIZE {
            for l in 0..<4  {   // Using -1 to signal end of array.
                spread_sheets[i].numbers[j].value[l] = -1
            }
        }
    }
    numsIndx: int
    for line in strings.split_lines_iterator(&input) {
        it := line
        split := " "
        sheetIndx: int
        for str in strings.split_iterator(&it, split) {
            leng := len(str)
            tmp := strings.trim_space(str)
            for i in 0..<leng {
                num := strconv.atoi(tmp[i:i+1])
                //fmt.println(num)
                //fmt.println(i)
                spread_sheets[sheetIndx].numbers[numsIndx].value[i] = num
            }
            sheetIndx += 1
        }
        numsIndx += 1
    }
    free_all(context.temp_allocator)
    for nums in 0..<SIZE {
        fmt.printfln("Sheet %v", nums+1)
        for sheets in 0..<SIZE {
            fmt.println(spread_sheets[nums].numbers[sheets].value)
        }
    }
    total: int
    for i in 0..<SIZE {
        for j in 0..<SIZE {
            total += high_low_diff(spread_sheets[i].numbers[j].value[:])
        }
    }
    fmt.println(total)
}

high_low_diff :: proc(nums: []int) -> int {
    h: int = nums[0]
    l: int = nums[0]
    for i in 0..<4 {
        if nums[i] == -1 {
            break
        }
        if h < nums[i] {
            h = nums[i]
        }
        if l > nums[i] {
            l = nums[i]
        }
    }
    return h-l
}