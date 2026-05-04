package day05_2023

import f "core:fmt"
import "core:os"

main :: proc() {
    // file, err := os.read_entire_file("input", context.allocator)
    file, err := os.read_entire_file("example", context.allocator)
    check_err(err)

    grow_map := parse_input(file)

    locs: [dynamic]int
    for seed in grow_map.seeds {
        loc := process_seed(&grow_map, seed)
        append(&locs, loc)
    }
    ans := locs[0]
    for i in 1 ..< len(locs) {
        if ans > locs[i] {
            ans = locs[i]
        }
    }
    f.println("Part 1 answer:", ans)

    l := len(grow_map.seeds)
    seed_rngs := make_seed_ranges(grow_map.seeds)
    fin_out := process_ranges(seed_rngs[:], grow_map)
    ans = fin_out[0].x
    for rng in fin_out {
        if ans > rng.x {
            ans = rng.x
        }
    }
    f.println("Part 2 answer", ans)
}
