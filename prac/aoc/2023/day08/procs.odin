package day08_2023

import f "core:fmt"
import "core:os"
import s "core:strings"

Map :: struct {
    directions:   string,
    destinations: map[string][2]string,
}

parse_input :: proc(file: ^[]u8) -> (m: Map) {

    str_file := string(file^)

    for line in s.split_lines_iterator(&str_file) {

        if line == "" do continue

        if s.contains_rune(line, '=') {
            start := line[:3]
            dest1 := line[7:10]
            dest2 := line[12:15]
            m.destinations[start] = {dest1, dest2}

        } else {
            m.directions = line[:]
        }
    }

    return m
}

// Count the moves it will take to go from `AAA` -> `ZZZ`.
from_AAA_to_ZZZ :: proc(m: Map) -> (moves: int) {

    pos := "AAA"
    l := len(m.directions[:])

    for i := 0; i < l; i += 1 {
        dir := m.directions[i]
        moves += 1

        if dir == 'L' {
            // Use dest1 if 'L'
            pos = m.destinations[pos].x
        } else {
            // Use dest2 if 'R'
            pos = m.destinations[pos].y
        }

        if pos == "ZZZ" {
            break

        } else if i == l - 1 {
            i = -1
        }
    }

    return moves
}

// Return a list of all start positions that end in `A`.
list_ends_in_A :: proc(m: Map) -> []string {

    list: [dynamic]string

    for start in m.destinations {
        if ends_in('A', start) {
            append(&list, start)
        }
    }

    return list[:]
}

// Returns a list of how many moves a loop will be for each start position.
loop_counter :: proc(m: Map, starters: []string) -> []int {

    list: [dynamic]int
    l := len(m.directions)

    for s in starters {
        pos := s
        moves: int

        for i := 0; i < l; i += 1 {
            dir := m.directions[i]
            moves += 1

            if dir == 'L' {
                pos = m.destinations[pos].x
            } else {
                pos = m.destinations[pos].y
            }

            if ends_in('Z', pos) {
                break

            } else if i == l - 1 {
                i = -1
            }
        }
        append(&list, moves)
    }

    return list[:]
}

// Return true if `end` is the last element of `s`.
ends_in :: proc(end: u8, s: string) -> bool {

    l := len(s)

    if s[l - 1] == end {
        return true
    }

    return false
}

// Take list of loop lengths and calculate their Least Common Multiple.
process_loops_lengths :: proc(loops: []int) -> int {

    lcm := calculate_lcm(loops[0], loops[1])

    for l1 in loops[2:] {
        l2 := lcm
        lcm = calculate_lcm(l1, l2)
    }

    return lcm
}

calculate_lcm :: proc(n1, n2: int) -> int {
    return n1 * n2 / calculate_gcd(n1, n2)
}

// Calculate Greatest Common Divisor.
calculate_gcd :: proc(n1, n2: int) -> (gcd: int) {

    n1 := n1
    n2 := n2
    r := 1

    for r != 0 {
        gcd = r
        if n1 > n2 {
            r = n1 % n2
            n1 = r
        } else {
            r = n2 % n1
            n2 = r
        }
    }

    return gcd
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
