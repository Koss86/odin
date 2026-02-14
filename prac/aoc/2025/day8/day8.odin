package day8_2025

import "core:fmt"
import "core:os"
import "core:strconv"
import "core:strings"

INPUT_LEN :: 1000

Vec3 :: distinct [3]int
Int2 :: distinct [2]int

Connect :: struct {
    pos_1: Vec3,
    idx1:  int,
    pos_2: Vec3,
    idx2:  int,
    dist:  int,
}

main :: proc() {
    file, err := os.read_entire_file_from_path("input", context.allocator)
    // file, err := os.read_entire_file_from_path("example", context.allocator)
    check_err(err)
    str_file := string(file)
    locs_list: [dynamic]Vec3
    defer delete(file)
    defer delete(locs_list)

    for line in strings.split_lines_iterator(&str_file) {
        if line != "\n" {
            vec_buf: Vec3
            buf := make([dynamic]int)
            line := line
            for str_num in strings.split_iterator(&line, ",") {
                n, ok := strconv.parse_int(str_num)
                check_ok(ok)
                append(&buf, n)
            }
            vec_buf.x = buf[0]
            vec_buf.y = buf[1]
            vec_buf.z = buf[2]
            append(&locs_list, vec_buf)
            delete(buf)
        }
    }

    cons_list: [dynamic]Connect
    made_list_cons: map[Int2]bool // Track connections made in cons_list
    defer delete(made_list_cons)
    defer delete(cons_list)
    locs_size := len(locs_list)

    for i in 0 ..< locs_size {

        buf: Connect
        buf.idx1 = i
        buf.pos_1 = locs_list[i]

        for j in 0 ..< locs_size {
            if i == j || made_list_cons[{i, j}] {
                // If index is same or connection has already been made, skip it.
                continue
            }
            made_list_cons[{i, j}] = true
            made_list_cons[{j, i}] = true

            buf.idx2 = j
            buf.pos_2 = locs_list[j]
            buf.dist = distance_3d(buf.pos_1, buf.pos_2)
            append(&cons_list, buf)
        }
    }

    cons_list_arr := cons_list[:]
    msort_cons(&cons_list_arr)

    // Create union find struct.
    uf_map: [INPUT_LEN]int
    for i in 0 ..< INPUT_LEN {
        uf_map[i] = i
    }

    // Determine number of connections to make based off of input length.
    // example = 20
    // real input = 1000
    cons_to_make: int
    switch locs_size {
        case 20: cons_to_make = 10
        case INPUT_LEN: cons_to_make = INPUT_LEN
    }

    made_uf_cons: map[int]bool // Track connections made in uf_map
    defer delete(made_uf_cons)

    for i in 0 ..< cons_to_make {

        idx1 := cons_list[i].idx1
        idx2 := cons_list[i].idx2

        if made_uf_cons[idx1] && !made_uf_cons[idx2] {

            uf_map[idx2] = idx1
            made_uf_cons[idx2] = true

        } else if made_uf_cons[idx2] && !made_uf_cons[idx1] {

            uf_map[idx1] = idx2
            made_uf_cons[idx1] = true

        } else if !made_uf_cons[idx1] && !made_uf_cons[idx2] {

            uf_map[idx2] = idx1
            made_uf_cons[idx1] = true
            made_uf_cons[idx2] = true

        } else {

            r1 := find_root(idx1, &uf_map)
            r2 := find_root(idx2, &uf_map)

            if r1 != r2 {

                s1 := count_connected(r1, &uf_map, locs_size)
                s2 := count_connected(r2, &uf_map, locs_size)

                if s1 >= s2 {
                    uf_map[r2] = r1
                } else {
                    uf_map[r1] = r2
                }
            }
        }
    }

    root_cons: [dynamic]int
    defer delete(root_cons)
    for i in 0 ..< locs_size {
        if find_root(i, &uf_map) == i {
            n := count_connected(i, &uf_map, locs_size)
            append(&root_cons, n)
        }
    }

    root_cons_arr := root_cons[:]
    msort_root_cons(&root_cons_arr)
    total := root_cons[0] * root_cons[1] * root_cons[2]

    fmt.println("Part 1 answer:", total)

    cons_list_size := len(cons_list)

    // i := cons_to_make to pick up where we left off after Part 1.
    for i := cons_to_make; i < cons_list_size; i += 1 {

        idx1 := cons_list[i].idx1
        idx2 := cons_list[i].idx2

        if made_uf_cons[idx1] && !made_uf_cons[idx2] {

            uf_map[idx2] = idx1
            made_uf_cons[idx2] = true

        } else if made_uf_cons[idx2] && !made_uf_cons[idx1] {

            uf_map[idx1] = idx2
            made_uf_cons[idx1] = true

        } else if !made_uf_cons[idx1] && !made_uf_cons[idx2] {

            uf_map[idx2] = idx1
            made_uf_cons[idx1] = true
            made_uf_cons[idx2] = true

        } else {

            r1 := find_root(idx1, &uf_map)
            r2 := find_root(idx2, &uf_map)

            if r1 != r2 {

                s1 := count_connected(r1, &uf_map, locs_size)
                s2 := count_connected(r2, &uf_map, locs_size)

                if s1 >= s2 {
                    uf_map[r2] = r1
                } else {
                    uf_map[r1] = r2
                }
            }
        }
        if all_in_circuit(&uf_map) {
            total = cons_list[i].pos_1.x * cons_list[i].pos_2.x
            break
        }
    }
    fmt.println("Part 2 answer:", total)
}
