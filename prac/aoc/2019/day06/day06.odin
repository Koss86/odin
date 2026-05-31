package day06_2019

import f "core:fmt"
import "core:os"

main :: proc() {

    file, err := os.read_entire_file("input", context.allocator)
    // file, err := os.read_entire_file("example1", context.allocator)
    // file, err := os.read_entire_file("example2", context.allocator)
    check_err(err)

    orbits := parse_file(&file)
    list := id_list(orbits)
    uf := create_uf_map(len(list.list))
    init_orbit_uf(orbits, list, &uf)

    total: int
    COM := list.uf_idx["COM"]

    for _, i in uf {
        total += jumps_to_COM(&uf, i, COM)
    }

    f.println("Part 1 answer:", total)

    jumps := orbital_transfer("SAN", "YOU", &uf, list)

    f.println("Part 2 answer:", jumps)
}
