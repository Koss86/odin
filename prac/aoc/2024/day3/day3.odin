package aoc_2024_day3

import "core:os"
import "core:fmt"
import "core:slice"
import "core:strings"
import "core:strconv"
import "core:text/scanner"

MAX_MUL :: 12
MIN_MUL :: 8

main :: proc() {
    muls: [dynamic] string
    file:= "input.txt"
    data, ok := os.read_entire_file(file, context.allocator)
    if !ok {
        fmt.eprintfln("Error. Unable to open file.")
        return
    }
    defer delete(data, context.allocator)

    it := string(data)
    indx: int
    for line in strings.split_lines_iterator(&it) {
        n := len(line)
        nxt: for i in 0..<n {
            if line[i] == 'm' && line[i+1] == 'u' && line[i+2] == 'l' && line[i+3] == '(' {
                for j:=MIN_MUL-1; j < MAX_MUL; j += 1 {

                    if i+j >= n {
                        break nxt
                    }
                
                    if line[i+j] == ')' {
                        start := i+4
                        end := i+j
                        delimit: int
                        delimit = strings.index_any(line[i:end], ",")
                        if delimit == -1 {
                            fmt.println(line[start:end])
                            break nxt
                        }

                        for l in start..<delimit {
                            if line[l] < '0' || line[l] > '9' {
                                break nxt
                            }
                        }
                        for l in delimit+1..<end {
                            if line[l] < '0' || line[l] > '9' {
                                break nxt
                            }
                        }

                        if line[i+(j-1)] == ')' {
                            //fmt.println(line[start:end-1])
                            append(&muls, line[start:end-1])
                            break nxt
                        }
                        //fmt.println(line[start:end])
                        append(&muls, line[start:end])
                        indx += 1
                    }
                }
            }
        }
    }
    one, two, total: int
    for str in muls { // 87,556,383 too low. 171,049,841 wrong. 173,573,173 too high. wrong 169,296,326 169,352,256
        mul_str := str
        tmp, ok := strings.split_iterator(&mul_str, ",")
        one = strconv.atoi(tmp)
        //fmt.printf("%i ", one)

        tmp, ok = strings.split_iterator(&mul_str, ",")
        two = strconv.atoi(tmp)
        //fmt.println(two)
        if one < 0 || one > 999 {
            fmt.println("Oops. %v", one)
        } else if two < 0 || two > 999 {
            fmt.println("Oops. %v", two)
        }
        mul:= one*two
        total += mul
    }
    fmt.println(total)
}