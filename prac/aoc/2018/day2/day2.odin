package day2
import "core:os"
import "core:fmt"
import "core:slice"
import "core:strings"

main :: proc() {
    test: bool = false
    buff: [] byte
    ok: bool
    if test {
        buff, ok = os.read_entire_file("test.txt")
    } else {
        buff, ok = os.read_entire_file("../inputs/input2.txt")
    }
    if !ok {
        fmt.eprintln("Error. Unable to read file.")
        return
    }
    it := string(buff)
    box_ids := make([dynamic] string)
    for line in strings.split_lines_iterator(&it) {
        append(&box_ids, line)
    }
    run2: int
    run3: int
    for i in 0..<len(box_ids) {
        id := box_ids[i]
        seen_runes := make(map[rune]int)
        for j in 0..<len(id) {
            seen_runes[rune(id[j])] += 1
        }
        found2: bool
        found3: bool
        for key, value in seen_runes {
            if value == 2 {
                found2 = true
                
            } else if value == 3 {
                found3 = true
            }
        }
        if found2 {
            run2 += 1
        }
        if found3 {
            run3 += 1
        }
    }
    fmt.printfln("Part 1 answer: %v", run2*run3)

    for i in 0..<len(box_ids) {

        for j in i+1..<len(box_ids) {
            id1 := box_ids[i]
            id2 := box_ids[j]
            diff_count := 0
            diff_index := -1
            for l in 0..<len(id1) {
                if id1[l] != id2[l] {
                    diff_count += 1
                    diff_index = l
                }
                if diff_count > 1 {
                    break
                }
            }
            if diff_count == 1 {
                slice1 := id1[:diff_index]
                slice2 := id1[diff_index+1:]
                fmt.printfln("Part 2 answer: %v%v", slice1, slice2)
                return
            }
        }
    }
}