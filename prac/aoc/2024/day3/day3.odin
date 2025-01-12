package aoc_2024_day3

import "core:os"
import "core:fmt"
import "core:slice"
import "core:strings"
import "core:strconv"
import "core:text/scanner"

MAX_MUL :: 12
MIN_MUL :: 8

Mul :: string

main :: proc() {
    mul_strs:[dynamic] Mul
    file:= "input.txt"
    data, ok := os.read_entire_file(file, context.allocator)
    if !ok {
        fmt.eprintfln("Error. Unable to open file.")
        return
    }
    defer delete(data, context.allocator)

    it := string(data)
    x: int
    y: int
    indx: int
    for line in strings.split_lines_iterator(&it) {
        n := len(line)
         for i in 0..<n {
            if line[i] == 'm' && line[i+1] == 'u' &&
                line[i+2] == 'l' && line[i+3] == '(' {
                    for j:=MIN_MUL-1; j < MAX_MUL; j += 1 {

                        if (i+j) >= n {
                            continue
                        }

                        if line[i+j] == ')' {
                            begin := i+4
                            end := i+j
                            if line[i+5] != ',' {
                                if line[i+6] != ',' {
                                    if line[i+7] != ',' {
                                        continue
                                    }
                                }
                            }
 
                            if line[i+6] != ',' || line[i+6] <= '0' || line[i+6] >= '9' {
                                if line[i+7] != ',' || line[i+7] <= '0' || line[i+7] >= '9' {
                                    if line[i+8] <= '0' || line[i+8] >= '9' {
                                        
                                    }
                                }
                            }

                            append(&mul_strs, line[begin:end])
                            fmt.println(mul_strs[indx])
                            indx += 1

                        }
                    }
            }
        }
    }
     
}