package day11_2023

import f "core:fmt"
import "core:os"

Vec2 :: [2]int

parse_input :: proc(file: ^[]u8) -> [][]u8 {

    input_buf: [dynamic][]u8
    buf: [dynamic]u8

    for r in file {
        if r == '\n' {
            append(&input_buf, buf[:])
            buf = make([dynamic]u8)
        } else {
            append(&buf, r)
        }
    }

    return input_buf[:]
}

// Return a list of the distances between each galaxy.
distances :: proc(galaxies: []Vec2) -> []int {

    paired: map[[2]Vec2]bool
    dists: [dynamic]int

    for i in 0 ..< len(galaxies) - 1 {

        g1 := galaxies[i]

        for j in i + 1 ..< len(galaxies) {

            g2 := galaxies[j]

            if !paired[{g1, g2}] {
                xx := abs(g2.x - g1.x)
                yy := abs(g2.y - g1.y)
                append(&dists, xx + yy)
                paired[{g1, g2}] = true
            }
        }
    }

    delete(paired)
    return dists[:]
}

// Return a list of corrodinates for each galaxy.
galaxy_list :: proc(input: ^[][]u8) -> []Vec2 {

    list: [dynamic]Vec2

    for y in 0 ..< len(input) {
        for x in 0 ..< len(input[0]) {
            if input[y][x] == '#' {
                append(&list, Vec2{x, y})
            }
        }
    }

    return list[:]
}

expand_universe :: proc(input: [][]u8) -> [][]u8 {

    input := input
    expand_idx_x, expand_idx_y := expand_list(&input)
    horizontal: [dynamic][]u8

    for row in input {
        append(&horizontal, expand_horizontal(expand_idx_x, row))
    }

    univrs_expanded := expand_vertical(expand_idx_y, horizontal[:])

    for row in horizontal {
        delete(row)
    }
    delete(horizontal)
    delete(expand_idx_x)
    delete(expand_idx_y)

    return univrs_expanded
}

// Since the `expand_idx_x/y` lists are the index location of a blank row/column.
// The lengths of the lists, or number of blanks, can be used to determine how much
// to increase galaxy positions that are below/right of said rows/columns.
// So, iterating through expand_idx in reverse allows us to increase
// the x/y position of galaxy positions that are > `idx` by using (`mul` * (`i` + 1)),
// Since `i` will indicate how many mul's to increase by.
expand_universe_p2 :: proc(input: ^[][]u8) -> []Vec2 {

    mul: int
    galaxies := galaxy_list(input)

    if len(galaxies) > 10 {
        mul = 999_999
    } else {
        mul = 99
    }

    expanded: map[Vec2]bool
    expand_idx_x, expand_idx_y := expand_list(input)

    #reverse for idx, i in expand_idx_x {
        for g, j in galaxies {
            if !expanded[g] && g.x > idx {
                galaxies[j].x += mul * (i + 1)
                expanded[galaxies[j]] = true
            }
        }
    }

    delete(expanded)
    expanded = make(map[Vec2]bool)

    #reverse for idx, i in expand_idx_y {
        for g, j in galaxies {
            if !expanded[g] && g.y > idx {
                galaxies[j].y += mul * (i + 1)
                expanded[galaxies[j]] = true
            }
        }
    }

    delete(expand_idx_x)
    delete(expand_idx_y)
    delete(expanded)
    return galaxies
}

// Expand along the x-axis by adding a '.' at the blank index + 1.
expand_horizontal :: proc(exp_list: []int, row: []u8) -> []u8 {

    l, r: int
    new_row: [dynamic]u8

    for l < len(exp_list) {

        if r != exp_list[l] + 1 {
            append(&new_row, row[r])
            r += 1

        } else {
            append(&new_row, '.')
            l += 1
        }
    }

    for r < len(row) {
        append(&new_row, row[r])
        r += 1
    }

    return new_row[:]
}

// Expand along the y-axis by adding a blank row at the blank index + 1.
expand_vertical :: proc(exp_list: []int, input: [][]u8) -> [][]u8 {

    blnk_row: [dynamic]u8
    for i in 0 ..< len(input[0]) {
        append(&blnk_row, '.')
    }

    l, i: int
    new_input: [dynamic][]u8

    for l < len(exp_list) {

        if i != exp_list[l] + 1 {
            append(&new_input, input[i])
            i += 1
        } else {
            append(&new_input, blnk_row[:])
            l += 1
        }
    }

    for i < len(input) {
        append(&new_input, input[i])
        i += 1
    }

    return new_input[:]
}

// Create two lists containing the index of blank rows and columns.
// exp_list_x contains the blank column indexes since it will expand in the x axis.
// exp_list_y contains the blank row indexes since it will expand in the y axis.
expand_list :: proc(input: ^[][]u8) -> ([]int, []int) {

    exp_list_x, exp_list_y: [dynamic]int
    y_axis := len(input)
    x_axis := len(input[0])

    for idx in 0 ..< x_axis {
        if blank_xy(idx, input, 'y') {
            append(&exp_list_x, idx)
        }
    }

    for idx in 0 ..< y_axis {
        if blank_xy(idx, input, 'x') {
            append(&exp_list_y, idx)
        }
    }

    return exp_list_x[:], exp_list_y[:]
}

// Checks if the given row or column is blank.
blank_xy :: proc(idx: int, input: ^[][]u8, check: u8) -> bool {

    if check == 'x' {
        x_axis := len(input[0])
        for i in 0 ..< x_axis {
            if input[idx][i] != '.' {
                return false
            }
        }

    } else if check == 'y' {
        y_axis := len(input)
        for i in 0 ..< y_axis {
            if input[i][idx] != '.' {
                return false
            }
        }
    }

    return true
}

check_err :: proc(err: os.Error, loc := #caller_location) {
    if err != nil {
        f.printfln("Error: %v - %v", err, loc)
        os.exit(1)
    }
}
