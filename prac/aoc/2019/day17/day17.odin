package day17_2019

import "../../util"
import f "core:fmt"
import "core:os"

main :: proc() {
    input: string
    args := os.args

    if len(args) > 1 do input = args[1]
    else do input = "input"

    file, err := os.read_entire_file(input, context.allocator)
    util.check_err(err)

    intcode1 := util.init_intcode(file)
    intcode2 := util.copy_map(intcode1)

    image := construct_image(intcode1)
    intersecs := list_intersecs(image)
    ans1: int
    for pos in intersecs { ans1 += pos.x * pos.y }

    routine := main_routine(image)
    ans2 := notify_robots(routine, 'n', intcode2)

    // Set feed to 'y' to print camera feed after every move.
    // ans2 := notify_robots(routine, 'y', intcode2)

    f.println("Part 1 answre:", ans1)
    f.println("Part 2 answer:", ans2)
}
