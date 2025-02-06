package day1
import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"

main :: proc() {
    buff, ok := os.read_entire_file_from_filename("../inputs/input1.txt", context.allocator)
    if !ok {
        fmt.eprintln("Error. Unable to read file.")
        return
    }
    
    frequency: int
    it := string(buff)
    direcs := make([dynamic] int)

    for line in strings.split_lines_iterator(&it) {
            num := strconv.atoi(line)
            frequency += num
            append(&direcs, num)
    }
    fmt.printfln("Part 1 answer: %v", frequency)

    frequency = 0
    seen_frequencies := make(map[int]bool)
    seen_frequencies[0] = true

    for {
        for i in 0..<len(direcs) {
            frequency += direcs[i]
            if seen_frequencies[frequency] {
                fmt.printfln("Part 2 answer: %i", frequency)
                return
            }
            seen_frequencies[frequency] = true
        }
    }
}