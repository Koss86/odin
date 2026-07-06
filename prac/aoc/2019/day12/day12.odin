package day12_2019

import f "core:fmt"
import "core:os"

main :: proc() {
    file, err := os.read_entire_file("input", context.allocator)
    check_err(err)

    run_examples()

    moons0 := parse_file(file)
    moons1 := parse_file(file)

    simulate_orbits(moons0, 1000)

    f.println("Part 1 answer:", calculate_energy(moons0))
    f.println("Part 2 answer:", loop_length(moons1))
}
