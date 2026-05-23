package day4
import "core:fmt"
import "core:strconv"

MIN :: 246515
MAX :: 739105

main :: proc() {
    
    buff := make([]byte, 8, context.allocator)
    valid_pws: int
    for n in MIN..=MAX {
        num := strconv.itoa(buff, n)
        if is_valid(num) {
            valid_pws += 1
        }
        
    }
    fmt.printfln("Part 1 answer: %v", valid_pws)
}

is_valid :: proc(str: string) -> bool {
    // Check length.
    if len(str) > 6 {
        return false
    }
    // Check if never decreasing.
    for i in 0..<len(str)-1 {
        if str[i] > str[i+1] {
            return false
        }
    }
    // Check if same adjacent.
    for i in 0..<len(str)-1 {
        if str[i] == str[i+1] {
            return true
        }
    }
    return false
}