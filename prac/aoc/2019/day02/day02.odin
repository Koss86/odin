package day02_2019

import f "core:fmt"
import "core:os"
import sl "core:slice"

main :: proc() {

    file, err := os.read_entire_file("input", context.allocator)
    // file, err := os.read_entire_file("example", context.allocator)
    check_err(err)

    intcode_p1 := parse_input(&file)
    intcode_p2 := sl.clone(intcode_p1)

    if len(intcode_p1) > 50 {

        // If full input change required values.
        intcode_p1[1] = 12
        intcode_p1[2] = 2
    }

    run_intcode_main(&intcode_p1)

    f.println("Part 1 answer:", intcode_p1[0])

    if len(intcode_p1) > 50 {
        ans := run_intcode_p2(intcode_p2)
        f.println("Part 2 answer:", ans)
    }
}
