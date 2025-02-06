package day2
import "core:os"
import "core:fmt"
import "core:slice"
import "core:strings"

main :: proc() {        // 672 too low
    buff, ok := os.read_entire_file("../inputs/input2.txt")
    if !ok {
        fmt.eprintln("Error. Unable to read file.")
        return
    }
    it := string(buff)
    box_ids := make([dynamic] string)
    for line in strings.split_lines_iterator(&it) {
        append(&box_ids, line)
    }
    seen_runes := make(map[rune]int)
    run2: int
    run3: int
    for i in 0..<len(box_ids) {
        id := box_ids[i]
        for j in 0..<len(id) {
            seen_runes[rune(id[j])] += 1
        }
        for j in 0..<len(seen_runes) {
            if seen_runes[rune(id[j])] == 2 {
                run2 += 1
            }
        }
        for j in 0..<len(seen_runes) {
            if seen_runes[rune(id[j])] == 3 {
                run3 += 1
            }
        }
    }
    fmt.println(run2)
    fmt.println(run3)
    fmt.println(run2*run3)
}