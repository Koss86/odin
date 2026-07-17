package day14_2019

import "../../util"
import f "core:fmt"
import "core:os"
import sc "core:strconv"
import s "core:strings"

Chemical :: struct {
    name: string,
    amt:  int,
}

Recipe :: struct {
    input: []Chemical,
    out:   Chemical,
}

parse_file :: proc(file: []u8) -> []Recipe {

    str := string(file)
    recipes: [dynamic]Recipe

    for line in s.split_lines_iterator(&str) {

        ok: bool
        r: Recipe
        dyn_in: [dynamic]Chemical
        i := s.index(line, "=>")
        inputs := line[:i]

        if s.contains(inputs, ",") {
            for chem in s.split_iterator(&inputs, ",") {
                append(&dyn_in, parse_chemical(chem))
            }
        } else {
            append(&dyn_in, parse_chemical(inputs))
        }

        r.input = dyn_in[:]
        r.out = parse_chemical(line[i + 2:])
        append(&recipes, r)
    }

    return recipes[:]
}

parse_chemical :: proc(str: string) -> (c: Chemical) {
    ok: bool
    str := s.trim_space(str)
    i := s.index(str, " ")
    c.name = str[i + 1:]
    c.amt, ok = sc.parse_int(str[:i])
    util.check_ok(ok)
    return c
}

fuel_ore_cost :: proc(list: []Recipe, amount: int) -> int {

    needs: map[string]int
    leftover: map[string]int
    defer delete(needs)
    defer delete(leftover)

    needs["FUEL"] = amount

    for {
        current: string
        for key, val in needs {
            if key != "ORE" && val > 0 {
                current = key
                break
            }
        }

        if current == "" { break }

        recipe: Recipe
        for r in list {
            if r.out.name == current {
                recipe = r
                break
            }
        }

        need := needs[current]

        if leftover[current] >= need {
            leftover[current] -= need
            needs[current] = 0
            continue
        } else {
            need -= leftover[current]
            leftover[current] = 0
        }

        batch_size := recipe.out.amt
        batches := (need + batch_size - 1) / batch_size
        produced := batches * batch_size
        leftover[current] += produced - need
        needs[current] = 0

        for input in recipe.input {
            needs[input.name] += input.amt * batches
        }
    }

    return needs["ORE"]
}

fuel_production :: proc(list: []Recipe) -> int {

    ore := 1_000_000_000_000
    cost := fuel_ore_cost(list, 1)
    lower := (ore / cost)
    upper := lower * 10
    target := lower

    for lower <= upper {

        mid := lower + (upper - lower) / 2
        cost = fuel_ore_cost(list, mid)

        if cost > ore {
            upper = mid - 1
        } else if cost < ore {
            lower = mid + 1
            target = mid
        }
    }

    return target
}

run_examples :: proc() {
    file, err := os.read_entire_file("example3", context.allocator)
    util.check_err(err)
    r := parse_file(file)
    ore_cost := fuel_ore_cost(r, 1)
    f.println("Example 1 part 1:", ore_cost)
    prod := fuel_production(r)
    f.println("Example 1 part 2:", prod)
    delete(file)
    delete(r)

    file, err = os.read_entire_file("example4", context.allocator)
    util.check_err(err)

    r = parse_file(file)
    ore_cost = fuel_ore_cost(r, 1)
    f.println("Example 2 part 1:", ore_cost)
    prod = fuel_production(r)
    f.println("Example 2 part 2:", prod, "\n")
    delete(file)
    delete(r)
}
