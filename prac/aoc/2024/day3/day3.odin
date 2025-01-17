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
    file:= "input2.txt"
    data, ok := os.read_entire_file(file, context.allocator)
    if !ok {
        fmt.eprintfln("Error. Unable to open file.")
        return
    }
    defer delete(data, context.allocator)

    it := string(data)
    indx: int
    do_: bool
    for line in strings.split_lines_iterator(&it) {
        n := len(line)
         for i in 0..<n {
            if line[i] == 'm' && line[i+1] == 'u' && line[i+2] == 'l' && line[i+3] == '(' {
                found: bool = false
                for j:=MIN_MUL-1; j < MAX_MUL; j += 1 {
                    
                    if i+j >= n || found {
                        continue
                    }
                    if line[i+j] == ')' {
                        dif := j
                        if line[i+5] != ',' {
                            if line[i+6] != ',' {
                                if line[i+7] != ',' {
                                    continue
                                }
                            }
                        }
                        found = true
                        start := i+4
                        end := i+j
                        append(&muls, line[start:end])
                        //fmt.println(indx, muls[indx])
                        indx += 1
                    }
                }
            }
        }
    }

   ct, one, two, total: int
    for str in muls { // 87,556,383 too low. 173,517,243  173,573,173 too high
        mul_str := str
        tmp, ok := strings.split_iterator(&mul_str, ",")
        //fmt.printf("%s ", tmp)
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