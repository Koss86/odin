package day06_2023

import f "core:fmt"
import "core:os"

main :: proc() {
    // file, err := os.read_entire_file("input", context.allocator)
    file, err := os.read_entire_file("example", context.allocator)

    time1, dist1 := parse_input_p1(file)
    win_list: [dynamic]int

    for t, i in time1 {

        to_beat := dist1[i]
        ct: int

        for h in 1 ..< t {
            d := h * (t - h)
            if d > to_beat {
                ct += 1
            }
        }
        if ct > 0 {
            append(&win_list, ct)
        }
    }

    ans := win_list[0]

    for i in 1 ..< len(win_list) {
        ans = ans * win_list[i]
    }
    f.println("Part 1 answer:", ans)

    ans = 0
    time2, dist2 := parse_input_p2(file)

    for h in 1 ..< time2 {
        d := h * (time2 - h)
        if d > dist2 {
            ans += 1
        }
    }
    f.println("Part 2 answer:", ans)
}
