package day9_2025

import "core:fmt"
import "core:os"
import "core:strconv"
import "core:strings"

Int2 :: [2]int

Square :: struct {
    c1:   [2]Int2,
    c2:   [2]Int2,
    area: int,
}

main :: proc() {
    file: []byte
    err: os.Error
    arg := os.args
    if len(arg) < 2 {
        file, err = os.read_entire_file_from_path("input", context.allocator)
    } else {
        file, err = os.read_entire_file_from_path(arg[1], context.allocator)
    }
    check_err(err)
    defer delete(file)

    str_file := string(file)
    input_list: [dynamic]Int2
    defer delete(input_list)

    for line in strings.split_lines_iterator(&str_file) {
        line := line
        buf: Int2
        y: bool
        for x_and_y in strings.split_iterator(&line, ",") {
            n, ok := strconv.parse_int(x_and_y)
            check_ok(ok)
            if y {
                buf.y = n
            } else {
                buf.x = n
                y = true
            }
        }
        append(&input_list, buf)
    }

    sq_pairs: [dynamic]Square
    con_made: map[Int2]bool
    defer delete(sq_pairs)

    input_size := len(input_list)
    // Generate sq_pairs and calculate area for each sq_pair.
    for i in 0 ..< input_size {
        c1 := input_list[i]
        for j in 0 ..< input_size {
            c2 := input_list[j]
            if i == j || con_made[{i, j}] {
                continue
            }
            buf: Square
            buf.c1.x = c1
            buf.c1.y = c2
            buf.area = find_area(c1, c2)
            append(&sq_pairs, buf)
            con_made[{i, j}] = true
            con_made[{j, i}] = true
        }
    }
    delete(con_made)

    sq_pairs_size := len(sq_pairs)

    // Get opposing corner coordinates for part 2.
    for i in 0 ..< sq_pairs_size {
        x1 := sq_pairs[i].c1[0].x
        y1 := sq_pairs[i].c1[0].y
        x2 := sq_pairs[i].c1[1].x
        y2 := sq_pairs[i].c1[1].y
        buf: [2]Int2 = {{x1, y2}, {x2, y1}}
        sq_pairs[i].c2 = buf
    }

    pairs_slc := sq_pairs[:]
    sort_squares(&pairs_slc)

    // Since sq_pairs was sorted high-low based off of the area,
    // the 1st element should be the answer for part 1.
    fmt.println("Part 1 answer:", sq_pairs[0].area)

    tile_edges: map[Int2]bool
    defer delete(tile_edges)

    for i in 0 ..< input_size - 1 {
        c1 := input_list[i]
        c2 := input_list[i + 1]
        connect_tiles(c1, c2, &tile_edges)
    }
    // Connect last to first square.
    connect_tiles(input_list[input_size - 1], input_list[0], &tile_edges)

    // Unfortantly part 2 takes anywhere from 5-8 minutes to complete depending on
    // the cpu and how far down the list it must go to find the answer for your input.
    fmt.println("Finding part 2 answer...")
    for i := 0; i < sq_pairs_size; i += 1 {
        corners: [2][2]Int2 = {sq_pairs[i].c1, sq_pairs[i].c2}
        if check_square(corners, &tile_edges) {
            // Print the grid if using smaller input.
            if input_size < 50 {
                list_slc := input_list[:]
                print_grid(corners.x, corners.y, &tile_edges, &list_slc)
            }

            fmt.println("Part 2 answer:", sq_pairs[i].area) // 1560475800
            break
        }
    }
}
