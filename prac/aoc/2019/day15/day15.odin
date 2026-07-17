package day15_2019

import "../../util"
import f "core:fmt"
import "core:os"

main :: proc() {

    file, err := os.read_entire_file("input", context.allocator)
    util.check_err(err)

    intcode := util.init_intcode(file)
    area, o2 := map_and_find_o2(&intcode)

    print_maze(area)

    ans := steps_to_o2(area, o2)
    f.println("Part 1 answer:", ans)

    ans = time_to_fill(area, o2)
    f.println("Part 2 answer:", ans)
}
