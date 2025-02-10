package day5
import "core:os"
import "core:fmt"
import "core:strings"



main :: proc() {
    buff, ok := os.read_entire_file("../inputs/input5.txt", context.temp_allocator)
    if !ok {
        fmt.eprintfln("Error. Unable to open file.")
        return
    }
    input := string(buff)
    leng := len(input)
    i := 0
    for i < leng-1 {
        cur_pos := input[i]
        nxt_pos := input[i+1]
        if (cur_pos >= 'A' && cur_pos <= 'Z' && nxt_pos == cur_pos + 32) ||
           (cur_pos >= 'a' && cur_pos <= 'z' && nxt_pos == cur_pos - 32) {
            input = strings.concat(input[0:i], input[i+2:leng])
            leng = len(input)
            if i > 0 {
                i -= 1
            }
        } else {
            i += 1
        }
    }
    fmt.printfln(input)
}