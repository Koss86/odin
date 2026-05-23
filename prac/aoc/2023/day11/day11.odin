package day11_2023

import f "core:fmt"
import "core:os"

main :: proc() {

    file, err := os.read_entire_file("input", context.allocator)
    // file, err := os.read_entire_file("example", context.allocator)
    check_err(err)

    universe_image := parse_input(&file)
    expanded_image := expand_universe(universe_image)
    galaxy_list := galaxy_list(&expanded_image)
    dist_list := distances(galaxy_list)

    total: int
    for v in dist_list {
        total += v
    }

    f.println("Part 1 answer:", total)

    expanded_p2 := expand_universe_p2(&universe_image)

    delete(dist_list)
    dist_list = distances(expanded_p2)

    total = 0
    for v in dist_list {
        total += v
    }

    f.println("Part 2 answer:", total)
}
