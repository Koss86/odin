package day3
import "core:os"
import "core:fmt"
import "core:strconv"
import "core:strings"

NUM_OF_RECTS :: 1373

Vec2 :: [2] int
Rectangle :: struct {
    x: int, y: int,
    width: int, height: int
}

main :: proc() {
    buff, ok := os.read_entire_file("../inputs/input3.txt")
    if !ok {
        fmt.eprintln("Error. Unable to read file.")
        return
    }

    elves_suggestions: [NUM_OF_RECTS] Rectangle
    it := string(buff)
    indx: int
    for line in strings.split_lines_iterator(&it) {
        first_run: bool = true
        tmp_str1 := line
        splits := []string { ",", ":", "x"}
        for str1 in strings.split_multi_iterate(&tmp_str1, splits[:]) {
            if first_run {
                tmp_str2 := str1
                split := "@"
                for s in strings.split_iterator(&tmp_str2, split) {
                    first_run = false
                    if !first_run {
                        elves_suggestions[indx].x = strconv.atoi(s)
                    }
                }
            }

        }
        indx += 1
    }
    for i in 0..<NUM_OF_RECTS {
        fmt.println(elves_suggestions[i].x)
    }

    the_fabric := make(map[Vec2]int, context.temp_allocator)
}