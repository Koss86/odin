package day13_2019

import f "core:fmt"
import "core:os"

main :: proc() {

    file, err := os.read_entire_file("input", context.allocator)
    check_err(err)

    intcode := parse_file(file)

    pos_id_list, _ := run_intcode(&intcode, 0)
    block_count := count_item(pos_id_list, BLOCK)
    delete(intcode)
    f.println("Part 1 answer:", block_count)

    intcode = parse_file(file)
    intcode[0] = 2
    score := beat_game(&intcode)
    f.println("Part 2 answer:", score)
}
