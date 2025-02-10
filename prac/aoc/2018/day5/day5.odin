package day5
import "core:os"
import "core:fmt"
import "core:slice"
import "core:strings"



main :: proc() {
    buff, ok := os.read_entire_file("../inputs/input5.txt", context.temp_allocator)
    if !ok {
        fmt.eprintfln("Error. Unable to open file.")
        return
    }
    orig_test_input := "dabAcCaCBAcCcaDA"
    tmp := string(buff)
    input := strings.clone(tmp, context.allocator)
    free_all(context.temp_allocator)
    leng := len(input)
    i := 0
    for i < leng-1 {        // 20780 too large.
        cur_pos := input[i]
        nxt_pos := input[i+1]
        if (cur_pos >= 'A' && cur_pos <= 'Z' && nxt_pos == cur_pos + 32) ||
           (cur_pos >= 'a' && cur_pos <= 'z' && nxt_pos == cur_pos - 32) {
            //fmt.println(input[i:i+1])   
            input, ok = strings.remove(input, input[i:i+1], 1, context.temp_allocator)
            free_all(context.allocator)
            //fmt.println(input[i:i+1])
            input, ok = strings.remove(input, input[i:i+1], 1, context.allocator)
            leng = len(input)
            free_all(context.temp_allocator)
            if i > 0 {
                i -= 1
            }
        } else {
            i += 1
        }
    }
    //fmt.println(input)
    fmt.printfln("%v", len(input))
    remove_elements(&input, 2000)
}
remove_elements :: proc(input: ^string, indx: int) {
    leng := len(input)
    for i := indx; i < leng-1; i += 1 {
        fmt.println(i)
    }
}