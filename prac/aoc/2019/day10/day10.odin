package day10_2019

import f "core:fmt"
import "core:os"

main :: proc() {
    file, err := os.read_entire_file("input", context.allocator)
    check_err(err)

    asteroids_map := parse_file(file)
    asteroids_pos := positions_of_map(asteroids_map)
    best_site := best_asterioid_site(asteroids_pos)
    most_visible := visible_from_site(best_site, asteroids_pos)

    run_examples(true)
    visualization(best_site, asteroids_pos, asteroids_map)

    f.println("Part 1 answer:", most_visible)

    quads := split_into_quadrants(best_site, asteroids_pos)
    pos := laser_asteroids(quads, best_site)
    f.println("Part 2 answer:", pos.x * 100 + pos.y)
}
