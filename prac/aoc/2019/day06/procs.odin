package day06_2019

import f "core:fmt"
import "core:os"
import s "core:strings"

Orbit_Map :: struct {
    id:       string,
    in_orbit: string,
}

List :: struct {
    list:   []string,
    uf_idx: map[string]int,
}

parse_file :: proc(file: ^[]u8) -> []Orbit_Map {

    orbits: [dynamic]Orbit_Map
    str_file := string(file^)

    for line in s.split_lines_iterator(&str_file) {
        i := s.index_rune(line, ')')
        buf: Orbit_Map
        buf.id = line[:i]
        buf.in_orbit = line[i + 1:]
        append(&orbits, buf)
    }

    return orbits[:]
}

// Setup the Union Find by starting at COM & joining every orbiting body
// to it's parent while noting every fork along the way.
// Once at the end of a branch start down the most recent fork detected.
init_orbit_uf :: proc(orbits: []Orbit_Map, list: List, uf: ^[]int) {

    nxt := "COM"
    orbits_len := len(orbits)
    orbit_mapped: map[int]bool
    fork_stack: [dynamic]string

    for _ in 0 ..< orbits_len {

        cur_orb, found := find_orbit(nxt, orbits, &orbit_mapped)

        if found {

            nxt = cur_orb.in_orbit
            id_1 := list.uf_idx[cur_orb.id]
            id_2 := list.uf_idx[cur_orb.in_orbit]
            uf[id_2] = id_1

            // f.printfln("%s<-%s %v<-%v", cur_orb.id, cur_orb.in_orbit, id_1, id_2)

            if a_fork(nxt, orbits) {
                append(&fork_stack, nxt)
                orbits_len += 1
                // +1 here so the loop dosent end
                // before all the forks are processed.
            }

        } else if len(fork_stack) > 0 {

            l := len(fork_stack)
            nxt = fork_stack[l - 1]
            ordered_remove(&fork_stack, l - 1)

        } else {
            f.println("error, fork detected but no forks.")
            os.exit(1)
        }
    }
    delete(orbit_mapped)
    delete(fork_stack)
}

// Trace the connection backwards from `l1` & `l2` for 1000 jumps (10 for example) or
// until they both reach `COM`, saving each jump location to a transfer list.
// Then search the transfer lists to find where they intersect.
orbital_transfer :: proc(l1, l2: string, uf: ^[]int, list: List) -> int {

    search_len: int

    if len(uf) < 20 {
        search_len = 10
    } else {
        search_len = 1000
    }

    l1 := list.uf_idx[l1]
    l2 := list.uf_idx[l2]
    COM := list.uf_idx["COM"]

    transfers_l1, transfers_l2: [dynamic]string
    defer delete(transfers_l1)
    defer delete(transfers_l2)

    for _ in 0 ..< search_len {
        l1 = uf[l1]
        l2 = uf[l2]
        append(&transfers_l1, list.list[l1])
        append(&transfers_l2, list.list[l2])
        if l1 == COM && l2 == COM do break
    }

    for i in 0 ..< len(transfers_l1) {
        for j in 0 ..< len(transfers_l1) {
            if transfers_l1[i] == transfers_l2[j] {
                return i + j
            }
        }
    }

    return 0
}

jumps_to_COM :: proc(uf: ^[]int, id: int, com: int) -> int {

    n: int
    x := id

    for x != com {
        x = uf[x]
        n += 1
    }

    return n
}

// If a parent body is listed as a parent twice in the Orbits map return true.
a_fork :: proc(id: string, orbits: []Orbit_Map) -> bool {

    n: int
    for o in orbits {
        if o.id == id {
            n += 1
            if n > 1 {
                return true
            }
        }
    }

    return false
}

// If `find` is found and not already been mapped, mark that Orbit_Map as mapped
// then return it. If not found/already mapped, return `false` to go down the next fork.
find_orbit :: proc(find: string, orbits: []Orbit_Map, mapped: ^map[int]bool) -> (Orbit_Map, bool) {

    orbit_map: Orbit_Map
    found: bool
    for o, i in orbits {
        if !mapped[i] && o.id == find {
            orbit_map = o
            found = true
            mapped[i] = true
            break
        }
    }

    return orbit_map, found
}

// Create a list of every id in the input. This will be the reference for the union find.
id_list :: proc(orbits: []Orbit_Map) -> List {

    dyn_list: [dynamic]string
    mapped: map[string]bool

    for o in orbits {
        if !mapped[o.id] {
            append(&dyn_list, o.id)
            mapped[o.id] = true
        }
        if !mapped[o.in_orbit] {
            append(&dyn_list, o.in_orbit)
            mapped[o.in_orbit] = true
        }
    }

    delete(mapped)
    uf_idx: map[string]int

    for id, i in dyn_list {
        uf_idx[id] = i
    }

    list: List
    list.list = dyn_list[:]
    list.uf_idx = uf_idx

    return list
}

create_uf_map :: proc(n: int) -> []int {
    uf: [dynamic]int
    for i in 0 ..< n {
        append(&uf, i)
    }
    return uf[:]
}

check_err :: proc(err: os.Error, loc := #caller_location) {
    if err != nil {
        f.printfln("Error: %v - %v", err, loc)
        os.exit(1)
    }
}
