package day5

import "core:os"
import "core:fmt"
import "core:sort"
import "core:slice"
import "core:strings"

main :: proc() {

    do_test :bool= false
    buff: []byte
    ok: bool
    if do_test {
        buff, ok = os.read_entire_file("test.txt", context.allocator)       
    } else {
        buff, ok = os.read_entire_file("../inputs/input5.txt", context.allocator)
    }
    if !ok {
        fmt.eprintfln("Error. Unable to open file.")
        return
    }
    defer delete(buff, context.allocator)

    orig_test_input := "dabAcCaCBAcCcaDA"
    tmp := string(buff)
    input := strings.clone(tmp, context.temp_allocator)
    leng := len(input)

    i := 0
    for i < leng-1 {

        cur_pos := input[i]
        nxt_pos := input[i+1]
        if (cur_pos >= 'A' && cur_pos <= 'Z' && nxt_pos == cur_pos + 32) ||
           (cur_pos >= 'a' && cur_pos <= 'z' && nxt_pos == cur_pos - 32) {
               if i > 0 {
                s1 := input[:i]
                s2 := input[i+2:]
                str := []string{ s1, s2 }
                input = strings.concatenate(str, context.temp_allocator)
                leng = len(input)
                i -= 1
            } else {
                s1 := ""
                s2 := input[i+2:]
                str := []string { s1, s2 }
                input = strings.concatenate(str, context.temp_allocator)
                leng = len(input) 
            }
        } else {
            i += 1
        }
    }

    part1 := len(input)
    fmt.printfln("Part 1 answer: %v", part1)

    free_all(context.temp_allocator)
    input = strings.clone(tmp, context.temp_allocator)
    alphas := [?]string {"a","b","c","d","e","f","g","h","i","j",
                            "k","l","m","n","o","p","q","r","s",
                                "t","u","v","w","x","y","z"}
    outter_leng := len(alphas)
    output_lengs: [26] int

    // This is really slow. It does iterate through the input 26 times though.
    for j in 0..<outter_leng {

        input, _ = strings.remove(input, alphas[j], -1, context.temp_allocator)
        cap := alphas[j]
        cap = strings.to_upper(cap, context.temp_allocator)
        input, _ = strings.remove(input, cap, -1, context.temp_allocator)
        leng = len(input)

        i = 0
        for i < leng-1 {
            cur_pos := input[i]
            nxt_pos := input[i+1]
            if (cur_pos >= 'A' && cur_pos <= 'Z' && nxt_pos == cur_pos + 32) ||
               (cur_pos >= 'a' && cur_pos <= 'z' && nxt_pos == cur_pos - 32) {
                   if i > 0 {
                    s1 := input[:i]
                    s2 := input[i+2:]
                    str := []string { s1, s2 }
                    input = strings.concatenate(str, context.temp_allocator)
                    leng = len(input)
                    i -= 1
                    } else {
                        s1 := ""
                        s2 := input[i+2:]
                        str := []string { s1, s2 }
                        input = strings.concatenate(str, context.temp_allocator)
                        leng = len(input)
                    }
            } else {
                i += 1
            }
        }
        output_lengs[j] = leng
        //fmt.printfln("removed: %v\nlength: %v", cap, len(input))
        free_all(context.temp_allocator)
        input = strings.clone(tmp, context.temp_allocator)
    }

    copy := output_lengs
    sort.quick_sort(copy[:])
    ans_indx := find_index(output_lengs[:], copy[:])
    fmt.printfln("Part 2 answer: %v %v", alphas[ans_indx], output_lengs[ans_indx])
}

find_index :: proc(orig: []int, sorted: []int) -> int {

    leng := len(orig)
    find := sorted[0]

    for i in 0..<leng {
        if orig[i] == find {
            return i
        }
    }
    return -1
}