package day03_2023

import "core:fmt"
import "core:os"
import "core:strings"

main :: proc() {
    file, err := os.read_entire_file("example", context.allocator)
    check_err(err)

    str_file := string(file)
    line_arr := strings.split_lines(str_file)
    l := len(line_arr)
    w := len(line_arr[0])
    schematic := line_arr[:]
    if schematic[l - 1] == "" {
        l -= 1
        schematic = line_arr[:l]
    }

    sum: int
    num_map: map[[2]int]int
    for y in 0 ..< l {
        for x := 0; x < w; x += 1 {
            if is_number(schematic[y][x]) {
                leng := number_length(schematic[y][x:])
                map_number({x, y}, leng, schematic[y][x:x + leng], &num_map)
                if is_valid_part_number(leng, {x, y}, schematic) {
                    sum += num_map[{x, y}]
                }
                // Move loop forward by the length of the number.
                x += leng - 1
            }
        }
    }
    fmt.println("Part 1 answer:", sum)

    sum = 0
    for y := 0; y < l; y += 1 {
        for x := 0; x < w; x += 1 {
            if schematic[y][x] == '*' {
                valid, ratio := check_gear({x, y}, schematic, &num_map)
                if valid {
                    sum += ratio
                }
            }
        }
    }
    fmt.println("Part 2 answer:", sum)
}
