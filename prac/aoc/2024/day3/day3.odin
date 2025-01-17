package aoc_2024_day3

import "core:os"
import "core:fmt"
import "core:strings"
import "core:strconv"

MAX :: 12
MIN :: 8

main :: proc() {
    muls: [dynamic] string
    file:= "input2.txt"
    data, ok := os.read_entire_file(file, context.allocator)
    if !ok {
        fmt.eprintfln("Error. Unable to open file.")
        return
    }
    defer delete(data, context.allocator)

    it := string(data)
    ct: int
    for line in strings.split_lines_iterator(&it) {

        n := len(line)

        nxt: for i in 0..<n {

            if line[i] == 'm' && line[i+1] == 'u' && line[i+2] == 'l' && line[i+3] == '(' {

                for j:=MIN-1; j < MAX; j += 1 {

                    if i+j >= n {

                        break nxt
                    }
                
                    if line[i+j] == ')' {

                        start := i+4
                        end := i+j

                        delimit: int
                        delimit = strings.index_any(line[i:end], ",")

                        if delimit == -1 {

                            //fmt.println(line[start:end])
                            break nxt
                        }
                        str := line[start:end]
                        tmp1, ok := strings.split_iterator(&str, ",")
                        tmp2, ok2 := strings.split_iterator(&str, ",")
                        //if ct < 10 {
                        //    fmt.printf("%v %v ", tmp1, tmp2)
                        //    ct += 1
                        //} else {
                        //    fmt.println()
                        //    ct = 0
                        //}

                        if line[i+(j-1)] == ')' {

                            //fmt.println(line[start:end-1])
                            append(&muls, line[start:end-1])
                            break nxt
                        }
                        //fmt.println(line[start:end])
                        append(&muls, line[start:end])
                    }
                }
            }
        }
    }
    one, two, total: int
    for str in muls { // 87,556,383 too low. 127,225,073 wrong. 171,049,841 wrong. 173,573,173 too high. wrong 169,296,326 169,352,256

        mul_str := str
        tmp, ok := strings.split_iterator(&mul_str, ",")

        //fmt.println(tmp)

        one = strconv.atoi(tmp)
        
        //fmt.printf("%i ", one)

        tmp, ok = strings.split_iterator(&mul_str, ",")

        //fmt.println(tmp)

        two = strconv.atoi(tmp)

        //fmt.println(two)

        mul:= one*two
        total += mul
    }
    fmt.println(total)
}