package day10_2023

import f "core:fmt"
import "core:os"
import s "core:strings"

main :: proc() {

    // file, err := os.read_entire_file("input", context.allocator)
    file, err := os.read_entire_file("example", context.allocator)
    check_err(err)

    str_arr := s.split_lines(string(file))
    pipe_mess := str_arr[:len(str_arr) - 1]

    start := gather_start_data(&pipe_mess)
    maze_len := maze_length(start, &pipe_mess)

    f.println("Part 1 answer:", maze_len / 2) // 6979

    corrds := maze_list(start, &pipe_mess)
    area := maze_area(corrds)

    // Calculate inteiror with pick's theorm.
    interior := area - (maze_len / 2) + 1

    f.println("Part 2 answer:", interior) // 443
}
