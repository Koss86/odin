package aoc_2024_day2

import "core:fmt"
import "core:os"
import "core:slice"
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
    size: int
    for i in 0..<N {
        if accend_or_decend_ok(unusual_data[i].data[:]) {
            safe_list[i] = true
        }
    }
    for i in 0..<N {
        size = arry_len(unusual_data[i].data[:])
        if safe_list[i] {
            safe_list[i] = is_dist_safe(unusual_data[i].data[:])
        }
    }

    total: int           
    for i in 0..<N {
        if safe_list[i] {
            total += 1
        }
    }
            // Print Part 1 answer
    fmt.printfln("Part 1 answer: %v", total)
    
    for i in 0..<N {
        list_loop: if !safe_list[i] {
            leng := arry_len(unusual_data[i].data[:])
            for j in 0..<leng {
                new_arry := remove_ele(slice.clone(unusual_data[i].data[:]), j)
                //fmt.printf("remove_ele success %v\nLeng = %v\n", j, leng)
                //fmt.printfln("old: %v\nnew: %v", unusual_data[i].data[:], new_arry)

                if accend_or_decend_ok(new_arry[:]) == true {

                    if is_dist_safe(new_arry[:]) == true{

                        safe_list[i] = true
                        break list_loop
                    }
                }
            }
        }
    }

    total = 0
    for i in 0..<N {
        if safe_list[i] {
            total += 1
        }
    }
                // Print Part 2 answer.
    fmt.printfln("Part 2 answer: %v", indx1) // 702 too high. 614 too low.
}

accend_or_decend_ok :: proc(data: [] int) -> bool {
    leng := arry_len(data)
    if data[0] > data[leng-1] {

        for i in 0..<leng-1 {
            if data[i] > data[i+1] {
                continue
            } else {
                return false
            }
        }

    } else {

        for i in 0..< leng-1 {
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

remove_ele :: proc(arry: []int, remove: int) -> [] int {
    leng := arry_len(arry)

    if remove == leng-1 { // if removing last element, just zero it and return it.
        arry[leng-1] = 0
        return arry
    }
    if remove == 0 {
        for i in 0..<leng-1 {
            arry[i] = arry[i+1]
        }
        arry[leng-1] = 0
    } else if remove == 1 {
        for i in 1..<leng-1 {
            arry[i] = arry[i+1]
        }
        arry[leng-1] = 0
    } else if remove == 2 {
        for i in 2..<leng-1 {
            arry[i] = arry[i+1]
        }
        arry[leng-1] = 0
    } else if remove == 3 {
        for i in 3..<leng-1 {
            arry[i] = arry[i+1]
        }
        arry[leng-1] = 0
    } else if remove == 4 {
        for i in 4..<leng-1 {
            arry[i] = arry[i+1] 
        }
        arry[leng-1] = 0
    } else if remove == 5 {
        for i in 5..<leng-1 {
            arry[i] = arry[i+1]
        }
        arry[leng-1] = 0
    } else if remove == 6 {
        arry[leng-2] = arry[leng-1]
        arry[leng-1] = 0
    }
    return arry    
}