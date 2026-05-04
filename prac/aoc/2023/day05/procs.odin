package day05_2023

import f "core:fmt"
import "core:os"
import sc "core:strconv"
import s "core:strings"

Vec2 :: [2]int
MAP_NUM :: 7
EMPTY :: Vec2{0, 0}

Map_Type :: enum {
    seeds,
    seed_soil,
    soil_fert,
    fert_water,
    water_light,
    light_temp,
    temp_hum,
    hum_loc,
}

Map_Range :: struct {
    dest: Vec2,
    src:  Vec2,
}

Grow_Map :: struct {
    seeds:       []int,
    seed_soil:   [dynamic]Map_Range,
    soil_fert:   [dynamic]Map_Range,
    fert_water:  [dynamic]Map_Range,
    water_light: [dynamic]Map_Range,
    light_temp:  [dynamic]Map_Range,
    temp_hum:    [dynamic]Map_Range,
    hum_loc:     [dynamic]Map_Range,
}

parse_input :: proc(file: []u8) -> Grow_Map {
    grow_map: Grow_Map
    map_type: Map_Type
    str_file := string(file)
    map_ct: int

    for line in s.split_lines_iterator(&str_file) {

        if line == "" { continue }
        col_idx := s.index_rune(line, ':')

        if col_idx != -1 {
            map_type = change_map_type(map_ct)
            map_ct += 1
            if map_type == .seeds {
                str := line[col_idx + 1:]
                buf: [dynamic]int
                for num in s.split_iterator(&str, " ") {
                    if num != "" {
                        n, ok := sc.parse_int(num)
                        check_ok(ok)
                        append(&buf, n)
                    }
                }
                grow_map.seeds = buf[:]
            }
            continue
        }

        line := line
        dest, src, rng, it: int
        for map_num in s.split_iterator(&line, " ") {
            ok: bool
            switch it {
                case 0:
                    dest, ok = sc.parse_int(map_num)
                    check_ok(ok)
                case 1:
                    src, ok = sc.parse_int(map_num)
                    check_ok(ok)
                case 2:
                    rng, ok = sc.parse_int(map_num)
                    check_ok(ok)
            }
            it += 1
        }
        #partial switch map_type {
            case .seed_soil:
                append(&grow_map.seed_soil, define_map(dest, src, rng))
            case .soil_fert:
                append(&grow_map.soil_fert, define_map(dest, src, rng))
            case .fert_water:
                append(&grow_map.fert_water, define_map(dest, src, rng))
            case .water_light:
                append(&grow_map.water_light, define_map(dest, src, rng))
            case .light_temp:
                append(&grow_map.light_temp, define_map(dest, src, rng))
            case .temp_hum:
                append(&grow_map.temp_hum, define_map(dest, src, rng))
            case .hum_loc:
                append(&grow_map.hum_loc, define_map(dest, src, rng))
        }
    }
    return grow_map
}

// Run the seed number through each map and return the final location id.
process_seed :: proc(grow_map: ^Grow_Map, seed: int) -> (id: int) {
    id = seed
    for i in 0 ..< MAP_NUM {
        switch i {
            case 0:
                id = src_to_dest(id, grow_map.seed_soil[:])
            case 1:
                id = src_to_dest(id, grow_map.soil_fert[:])
            case 2:
                id = src_to_dest(id, grow_map.fert_water[:])
            case 3:
                id = src_to_dest(id, grow_map.water_light[:])
            case 4:
                id = src_to_dest(id, grow_map.light_temp[:])
            case 5:
                id = src_to_dest(id, grow_map.temp_hum[:])
            case 6:
                id = src_to_dest(id, grow_map.hum_loc[:])
        }
    }
    return id
}

// Run each seed range through each grow map mapping the intersecting ranges.
// Return the final location ranges produced from the seed ranges.
process_ranges :: proc(ranges: []Vec2, maps: Grow_Map) -> []Vec2 {

    fin_out: [dynamic]Vec2
    p_out: ^[dynamic]Vec2

    for i in 0 ..< len(ranges) {
        input: [dynamic]Vec2
        append(&input, ranges[i])

        for j in 0 ..< MAP_NUM {
            out: [dynamic]Vec2
            grow_map, map_type := get_map_and_type(j, maps)

            if map_type == .hum_loc {
                // If at last map assign p_out the address
                // of fin_out to pass back to main.
                p_out = &fin_out
            } else {
                p_out = &out
            }

            for len(input) > 0 {

                mapped: bool
                r := pop_range(&input)

                for rng in grow_map {

                    if range_within_range(r, rng.src) {
                        r.x = src_to_dest(r.x, grow_map)
                        r.y = src_to_dest(r.y, grow_map)
                        // Add mapped r to p_out for next iteration.
                        append(p_out, r)
                        mapped = true
                        break

                    } else if ranges_overlap(r, rng.src) {
                        splits := split_overlaps(r, rng.src)
                        buf: Vec2
                        buf.x = src_to_dest(splits[1].x, grow_map)
                        buf.y = src_to_dest(splits[1].y, grow_map)

                        // Add mapped splits[1] to p_out for next iteration.
                        append(p_out, buf)

                        for l := 0; l < 3; l += 2 {
                            if splits[l] != EMPTY {
                                // If not empty (0,0), add elements 0 & 2 of
                                // splits (pre, post) directly to input to be checked
                                // if they match other ranges in this map type.
                                append(&input, splits[l])
                            }
                        }
                        mapped = true
                        break
                    }
                }
                if !mapped {
                    // If not mapped, pass seed range to next iteration.
                    append(p_out, r)
                }
            }
            if map_type != .hum_loc {
                // If not at last map, move mapped ranges
                // from out to input for next iteration.
                for rng in p_out {
                    append(&input, rng)
                }
            }
            delete(out)
        }
        delete(input)
    }
    return fin_out[:]
}

get_map_and_type :: proc(n: int, maps: Grow_Map) -> (map_: []Map_Range, type: Map_Type) {
    switch n {
        case 0:
            map_ = maps.seed_soil[:]
            type = .seed_soil
        case 1:
            map_ = maps.soil_fert[:]
            type = .soil_fert
        case 2:
            map_ = maps.fert_water[:]
            type = .fert_water
        case 3:
            map_ = maps.water_light[:]
            type = .water_light
        case 4:
            map_ = maps.light_temp[:]
            type = .light_temp
        case 5:
            map_ = maps.temp_hum[:]
            type = .temp_hum
        case 6:
            map_ = maps.hum_loc[:]
            type = .hum_loc
    }
    return map_, type
}

range_within_range :: proc(r1, r2: Vec2) -> bool {
    if r1.x >= r2.x && r2.y >= r1.y {
        return true
    }
    return false
}

ranges_overlap :: proc(r1, r2: Vec2) -> bool {
    if r1.x < r2.x && r2.x < r1.y && r1.y < r2.y {
        return true
    } else if r2.x < r1.x && r1.x < r2.y && r2.y < r1.y {
        return true
    } else if r1.x == r2.x && r2.x < r1.y && r1.y > r2.y {
        return true
    } else if r1.x == r2.x && r2.x < r1.y && r1.y < r2.y {
        return true
    } else if r1.x < r2.x && r2.x < r1.y && r1.y == r2.y {
        return true
    } else if r1.x > r2.x && r2.x < r1.y && r1.y == r2.y {
        return true
    }
    return false
}

// Split overlapping ranges in UP TO three ranges. pre-overlap, overlap, post-overlap.
// Only caring about the splits that contain r1 (seed range).
// A split not containing r1 returns (0, 0).
split_overlaps :: proc(r1, r2: Vec2) -> (splits: [3]Vec2) {

    pre, ovrlp, post: Vec2
    if r1.x < r2.x && r2.x < r2.y && r2.y > r1.y {
        // (a,b) (c,d)
        // a...c...b...d
        pre = {r1.x, r2.x - 1}
        ovrlp = {r2.x, r1.y}

    } else if r1.x > r2.x && r2.x < r1.y && r1.y > r2.y {
        // c...a...d...b
        ovrlp = {r1.x, r2.y}
        post = {r2.y + 1, r1.y}

    } else if r1.x < r2.x && r2.x < r1.y && r1.y > r2.y {
        // a...c...d...b
        pre = {r1.x, r2.x - 1}
        ovrlp = {r2.x, r2.y}
        post = {r2.y + 1, r1.y}
    } else if r1.x < r2.x && r2.x < r1.y && r1.y == r2.y {
        // a...c...b&d
        pre = {r1.x, r2.x - 1}
        ovrlp = {r2.x, r2.y}

    } else if r1.x == r2.x && r2.x < r1.y && r1.y > r2.y {
        // a&c...d...b
        ovrlp = {r1.x, r2.y}
        post = {r2.y + 1, r1.y}

    }
    splits = {pre, ovrlp, post}
    return splits

}

pop_range :: proc(stack: ^[dynamic]Vec2) -> Vec2 {
    range := stack[0]
    ordered_remove(stack, 0)
    return range
}

make_seed_ranges :: proc(seeds: []int) -> [dynamic]Vec2 {
    l := len(seeds)
    seed_rngs: [dynamic]Vec2
    for i := 0; i < l - 1; i += 2 {
        buf: Vec2
        buf.x = seeds[i]
        buf.y = seeds[i] + seeds[i + 1] - 1
        append(&seed_rngs, buf)
    }
    return seed_rngs
}

// Determine the next destination number from source number and the given map.
src_to_dest :: proc(id: int, map_t: []Map_Range) -> (nxt_id: int) {
    mapped: bool
    map_idx: int
    for m, i in map_t {
        if id >= m.src.x && id <= m.src.y {
            mapped = true
            map_idx = i
            break
        }
    }
    if mapped {
        diff := id - map_t[map_idx].src.x
        nxt_id = map_t[map_idx].dest.x + diff
    } else {
        nxt_id = id
    }
    return nxt_id
}

change_map_type :: proc(n: int) -> (nxt_map: Map_Type) {
    switch n {
        case 0:
            nxt_map = .seeds
        case 1:
            nxt_map = .seed_soil
        case 2:
            nxt_map = .soil_fert
        case 3:
            nxt_map = .fert_water
        case 4:
            nxt_map = .water_light
        case 5:
            nxt_map = .light_temp
        case 6:
            nxt_map = .temp_hum
        case 7:
            nxt_map = .hum_loc
    }
    return nxt_map
}

define_map :: proc(dest, src, rng: int) -> (map_: Map_Range) {
    map_.dest = {dest, dest + rng - 1}
    map_.src = {src, src + rng - 1}
    return map_
}

check_ok :: proc(ok: bool, loc := #caller_location) {
    if !ok { panic("something's not ok", loc) }
}

check_err :: proc(err: os.Error, loc := #caller_location) {
    if err != nil {
        f.printfln("error: %v - %v", err, loc)
        os.exit(1)
    }
}
