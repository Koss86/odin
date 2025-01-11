package aoc_2024_day2

import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"

N :: 1000
N2 :: 415

Arry_i8 :: struct {
    data: [8] int
}

main :: proc() {
    
    file := "../input.txt"
    buff, ok := os.read_entire_file(file, context.allocator)
    if !ok {
        fmt.eprintfln("Error: Unable to open file.")
    }
    defer delete(buff, context.allocator)
    it := string(buff)
    indx1: int
    indx2: int
    unusual_data: [N] Arry_i8
    for line in strings.split_lines_iterator(&it) {
        if !ok {
            fmt.eprintfln("Error in split_lines_iterator")
        }
        it2 := line
        split := [?] string{ " " }
        for str in strings.split_multi_iterate(&it2, split[:]) {
            if !ok {
                fmt.eprintfln("Error in split_multi_iterate")
            }
            atoi := strconv.atoi(str)
            unusual_data[indx1].data[indx2] = atoi
            indx2 += 1
        }
        indx1 += 1
        indx2 = 0
    }
            // Debugging
    //for i in 0..<N {
    //    indx1 = 0
    //    for j in 0..<8 {
    //        fmt.printf("%i ", unusual_data[i].data[j])  
    //    }
    //    fmt.println("")
    //}
    safe_list: [N] bool
    for i in 0..<N {
        if accend_or_decend_ok(unusual_data[i].data[:]) {
            safe_list[i] = true
        }
    }
    for i in 0..<N {
        if safe_list[i] {
            safe_list[i] = is_dist_safe(unusual_data[i].data[:])
        }
    }

    indx1 = 0           // reusing indx1 to count safe list
    for i in 0..<N {
        if safe_list[i] {
            indx1 += 1
        }
    }
            // Debugging
    //for i in 0..<N {
    //    if safe_list[i] {
    //        fmt.printfln("Index %v is safe.", i+1)
    //    } else {
    //        fmt.printfln("Index %v is unsafe.", i+1)
    //    }
    //}
            // Print Part 1 answer
    fmt.printfln("Part 1 answer: %v", indx1)
    list_copy := safe_list
    for i in 0..<N {
        if !safe_list[i] {
            //fmt.printfln("safe index: %v", i)
            safe_list[i] = rem_accend_or_decend_ok(unusual_data[i].data[:])
            //if safe_list[i] {
            //    safe_list[i] = rem_is_dist_safe(unusual_data[i].data[:]) 
            //} 
        }
    }
    for i in 0..<N {
        if !safe_list[i] {
            safe_list[i] = rem_is_dist_safe(unusual_data[i].data[:])
        }
    }

    indx1 = 0
    for i in 0..<N {
        if safe_list[i] {
            indx1 += 1
        }
    }
                // Print Part 2 answer.
    fmt.printfln("Part 2 answer: %v", indx1) // 702 too high. 614 too low.
}

accend_or_decend_ok :: proc(data: [] int) -> bool {

    n := arry_len(data)
    if data[0] > data[n-1] {

        for i in 0..<n-1 {
            if data[i] > data[i+1] {
                continue
            } else {
                return false
            }
        }

    } else {

        for i in 0..< n-1 {
            if data[i] < data[i+1] {
                continue
            } else {
                return false
            }
        }
    }
    return true
}

is_dist_safe :: proc (arry: []int) -> bool {
    dist: int
    cur: int
    nxt: int
    n := arry_len(arry)
    for i in 0 ..< n-1 {
        cur = arry[i]
        nxt = arry[i+1]
        if cur < nxt {
            dist = nxt - cur
        } else {
            dist = cur - nxt
        }
        if dist > 3 {
            return false
        }
    }
    return true
}

arry_len :: proc(arry: []int) -> int {
    size: int
    outter: for v in arry {
        if v == 0 {
            break outter
        }
        size += 1
    }
    return size
}

rem_accend_or_decend_ok :: proc(data: [] int) -> bool {
    n := arry_len(data)
    cur: int
    nxt: int
    unsafe: int
    is_safe: int
    if data[0] > data[n-1] {

        for i in 0..<n-1 {          // var i is the index to the number we want to skip
            cur = data[i]
            nxt = data[i+1]
            for j in 0..<n-1 {      // here we check if list is safe while skipping the index = to i

                if j == i-1 {       // here stops us from comparing j with index we want to skip

                    if data[j] > data[j+2] {
                        continue
                    } else {
                        unsafe += 1
                        continue
                    }
                }

                if j == i {
                    continue
                }

                if data[j] > data[j+1] {
                    continue
                } else {
                    unsafe = true
                }
            }
        }
    } else {
        for i in 0..<n-1 {
            cur = data[i]
            nxt = data[i+1]
            for j in 0..<n-1 {
                if i == n-2 { // if index we want to skip is last in array.

                }
                if j == i {
                    continue
                }
                if data[j] < data[j+1] {
                    continue
                } else {
                    unsafe = true
                }
            }
        }
    }
    if unsafe {
        return false
    } else {
        return true
    }
}

rem_is_dist_safe :: proc (arry: []int) -> bool {
    dist: int
    cur: int
    nxt: int
    failed: bool
    n := arry_len(arry)
    for i in 0 ..< n-1 {
        cur = arry[i]
        nxt = arry[i+1]
        for j in 0..<n-1 {
            if j == i {
                continue
            } else if i == n-2 {
                continue
            } else if j+1 == i {
                nxt = arry[i+2]
                }
            
            if cur < nxt {
                dist = nxt - cur
            } else {
                dist = cur - nxt
            }
            if dist > 3 {
                failed = true
            }
        }
    }
    if failed {
        return false
    } else {
        return true
    }
}