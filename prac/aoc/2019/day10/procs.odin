package day10_2019

import f "core:fmt"
import "core:math"
import "core:os"
import sl "core:slice"
import s "core:strings"

Vec2 :: [2]int

Asteroid :: struct {
    pos:   Vec2,
    dist:  int,
    slope: Vec2,
}

// Turn input into a list of strings.
parse_file :: proc(file: []u8) -> []string {

    str := string(file)
    map_: [dynamic]string

    for line in s.split_lines_iterator(&str) {
        append(&map_, line)
    }

    return map_[:]
}

// Turn a list of strings into a list of positions.
positions_of_map :: proc(map_: []string) -> []Vec2 {

    list: [dynamic]Vec2

    for y in 0 ..< len(map_) {
        for x in 0 ..< len(map_[0]) {
            if map_[y][x] == '#' {
                append(&list, Vec2{x, y})
            }
        }
    }

    return list[:]
}

// Return the coordinates of the site where the most asteroids are visible.
best_asterioid_site :: proc(list: []Vec2) -> Vec2 {

    site: Vec2
    visible := visible_from_site(list[0], list)

    for i in 1 ..< len(list) {
        nxt := visible_from_site(list[i], list)
        if nxt > visible {
            visible = nxt
            site = list[i]
        }
    }

    return site
}

// Get the number of visible asteroids by finding the slope of each
// asteroid from `site` then returning the number of unique slopes.
visible_from_site :: proc(site: Vec2, list: []Vec2) -> int {

    slopes: map[Vec2]bool
    for pos in list {
        if pos != site {
            dx := pos.x - site.x
            dy := pos.y - site.y
            gcd := math.gcd(dx, dy)
            slope := Vec2{dx / gcd, dy / gcd}
            slopes[slope] = true
        }
    }
    delete(slopes)
    return len(slopes)
}

// Create a map of the closest asteroids to `site`.
map_visible_asteroids :: proc(site: Vec2, list: []Vec2) -> map[Vec2]bool {

    visible: map[Vec2]bool
    seen_slopes: map[Vec2]bool
    slope_list := create_dist_slope_list(site, list)

    for control in slope_list {
        if !seen_slopes[control.slope] {

            dist := control.dist
            closest_pos_on_slope := control.pos

            for cur in slope_list {
                if cur.pos != site && cur.slope == control.slope && cur.dist < dist {
                    dist = cur.dist
                    closest_pos_on_slope = cur.pos
                }
            }
            seen_slopes[control.slope] = true
            visible[closest_pos_on_slope] = true
        }
    }

    delete(slope_list)
    delete(seen_slopes)

    return visible
}

// Creates a list of each asteroids distance, slope, & position.
create_dist_slope_list :: proc(site: Vec2, list: []Vec2) -> []Asteroid {

    l: [dynamic]Asteroid
    for pos, i in list {
        if pos != site {
            dx := pos.x - site.x
            dy := pos.y - site.y
            gcd := math.gcd(dx, dy)
            tmp: Asteroid
            tmp.pos = pos
            tmp.dist = dx * dx + dy * dy
            tmp.slope = Vec2{dx / gcd, dy / gcd}
            append(&l, tmp)
        }
    }

    return l[:]
}

// With `site` as the center, divide each position into its corresponding quadrant.
split_into_quadrants :: proc(site: Vec2, list: []Vec2) -> [][]Vec2 {

    up_right, down_right, down_left, up_left: [dynamic]Vec2

    for pos in list {
        if pos != site {
            if pos.x >= site.x {
                if pos.y <= site.y {
                    append(&up_right, pos)
                } else {
                    append(&down_right, pos)
                }
            } else {
                if pos.y <= site.y {
                    append(&up_left, pos)
                } else {
                    append(&down_left, pos)
                }
            }
        }
    }

    quads: [dynamic][]Vec2
    append(&quads, up_right[:])
    append(&quads, down_right[:])
    append(&quads, down_left[:])
    append(&quads, up_left[:])

    return quads[:]
}

// Scan the `quadrants` (clockwise) "removing" each asteroid found to be visible from `site`.
// Once the 200th asteroid has been removed, return that asteroids position.
laser_asteroids :: proc(quadrants: [][]Vec2, site: Vec2) -> Vec2 {

    r: int
    for quad in quadrants {
        visible := list_visible_from_site(site, quad)
        defer delete(visible)
        sort(visible, site)
        for i in 0 ..< len(visible) {
            r += 1
            if r == 200 do return visible[i]
        }
    }
    return 0
}

// Create a list of positions visible from `site`.
list_visible_from_site :: proc(site: Vec2, list: []Vec2) -> []Vec2 {

    visible: [dynamic]Vec2
    map_ := map_visible_asteroids(site, list)
    for k in map_ { append(&visible, k) }
    delete(map_)

    return visible[:]
}

// Sort positions based off of their angle from `site`.
sort :: proc(main: $T/[]$E, site: Vec2) {
    leng := len(main)
    if leng > 1 {
        mid := leng / 2
        left := sl.clone(main[:mid])
        right := sl.clone(main[mid:])
        sort(left, site)
        sort(right, site)
        merge(left, right, main, site)
        delete(left)
        delete(right)
    }
}

merge :: proc(left, right, main: $T/[]$E, site: Vec2) {

    l_len := len(left)
    r_len := len(right)
    l, r, m: int

    for l < l_len && r < r_len {
        d1 := left[l] - site
        d2 := right[r] - site
        if (d2.x * d1.y) - (d1.x * d2.y) < 0 {
            main[m] = left[l]
            l += 1
            m += 1
        } else {
            main[m] = right[r]
            r += 1
            m += 1
        }
    }
    for l < l_len {
        main[m] = left[l]
        l += 1
        m += 1
    }
    for r < r_len {
        main[m] = right[r]
        r += 1
        m += 1
    }
}

// Print the asteroid map with colors for `site`, visible asteroids, & non-visible asteroids.
visualization :: proc(site: Vec2, list: []Vec2, map_: []string) {

    vis_map := map_visible_asteroids(site, list)
    defer delete(vis_map)

    for row, y in map_ {
        for r, x in row {
            pos: Vec2 = {x, y}
            if pos == site {
                f.printf("\e[34m%v\e[m", r)
            } else if vis_map[pos] {
                f.printf("\e[32m%v\e[m", r)
            } else if r == '#' {
                f.printf("\e[31m%v\e[m", r)
            } else {
                f.printf(".")
            }
        }
        f.printf("\n")
    }
}

run_examples :: proc(print := false) {

    context.allocator = context.temp_allocator
    defer free_all(context.temp_allocator)

    ///////////// Example 1 /////////////////

    file, err := os.read_entire_file("example1", context.allocator)
    check_err(err)

    asteroids_map := parse_file(file)
    asteroids_pos := positions_of_map(asteroids_map)
    best_site := best_asterioid_site(asteroids_pos)
    most_visible := visible_from_site(best_site, asteroids_pos)

    if print do visualization(best_site, asteroids_pos, asteroids_map)

    f.println("Example 1:", most_visible)
    if print do f.printf("\n")

    ///////////// Example 2 /////////////////

    file, err = os.read_entire_file("example2", context.allocator)
    check_err(err)

    asteroids_map = parse_file(file)
    asteroids_pos = positions_of_map(asteroids_map)
    best_site = best_asterioid_site(asteroids_pos)
    most_visible = visible_from_site(best_site, asteroids_pos)

    if print do visualization(best_site, asteroids_pos, asteroids_map)

    f.println("Example 2:", most_visible)
    if print do f.printf("\n")

    ///////////// Example 3 /////////////////

    file, err = os.read_entire_file("example3", context.allocator)
    check_err(err)

    asteroids_map = parse_file(file)
    asteroids_pos = positions_of_map(asteroids_map)
    best_site = best_asterioid_site(asteroids_pos)
    most_visible = visible_from_site(best_site, asteroids_pos)

    if print do visualization(best_site, asteroids_pos, asteroids_map)

    f.println("Example 3:", most_visible)
    if print do f.printf("\n")

    ///////////// Example 4 /////////////////

    file, err = os.read_entire_file("example4", context.allocator)
    check_err(err)

    asteroids_map = parse_file(file)
    asteroids_pos = positions_of_map(asteroids_map)
    best_site = best_asterioid_site(asteroids_pos)
    most_visible = visible_from_site(best_site, asteroids_pos)

    if print do visualization(best_site, asteroids_pos, asteroids_map)

    f.println("Example 4:", most_visible)
    if print do f.printf("\n")

    ///////////// Example Part 2 /////////////////

    quads := split_into_quadrants(best_site, asteroids_pos)
    pos := laser_asteroids(quads, best_site)
    f.println("Example Part 2:", pos.x * 100 + pos.y)
    // if print do f.printf("\n")
}

check_ok :: proc(ok: bool, loc := #caller_location) {
    if !ok do panic("Something's not ok", loc)
}

check_err :: proc(err: os.Error, loc := #caller_location) {
    if err != nil {
        f.printfln("Error: %v - %v", err, loc)
        os.exit(1)
    }
}
