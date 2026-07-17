package day14_2019

import "../../util"
import f "core:fmt"
import "core:os"

main :: proc() {
    run_examples()

    file, err := os.read_entire_file("input", context.allocator)
    util.check_err(err)

    recipes := parse_file(file)

    ore_cost := fuel_ore_cost(recipes, 1)
    f.println("Part 1 answer:", ore_cost)

    prod := fuel_production(recipes)
    f.println("Part 2 answer:", prod)
}
