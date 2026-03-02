package day9_2025

import "core:fmt"
import "core:os"
import "core:slice"

// Take the 4 coordinates of a square and check if they are valid for part 2.
check_square :: proc(corners: [2][2]Int2, tile_edges: ^map[Int2]bool) -> bool {
    v1, v2, h1, h2: [2]Int2
    v1 = {corners[0].y, corners[1].y}
    v2 = {corners[0].x, corners[1].x}
    h1 = {corners[0].x, corners[1].y}
    h2 = {corners[0].y, corners[1].x}

    if !check_vertical(v1, v2, tile_edges) || !check_horizontal(h1, h2, tile_edges) {
        return false
    }
    return true
}
check_horizontal :: proc(h1, h2: [2]Int2, tile_edges: ^map[Int2]bool) -> bool {
    st, end: int
    inside, scanned: bool
    if h1[0].x < h1[1].x {
        st = h1[0].x
        end = h1[1].x
    } else {
        st = h1[1].x
        end = h1[0].x
    }
    for i := st; i <= end; i += 1 {
        // If not a tile edge, scan for edges.
        if !tile_edges[{i, h1[0].y}] {
            // Skip if determined to be inside tile edges by scan_x/scan_y.
            if !inside {
                // If not been scanned yet, check for edges.
                if !scanned {
                    if scan_y({i, h1[0].y}, tile_edges) {
                        inside = true
                        scanned = true
                    } else {
                        return false
                    }
                } else {
                    return false
                }
            }
        } else {
            // Reset 'inside' to detect when we leave the tile border.
            inside = false
        }
    }
    if h2[0].x < h2[1].x {
        st = h2[0].x
        end = h2[1].x
    } else {
        st = h2[1].x
        end = h2[0].x
    }
    inside = false
    scanned = false
    for i := st; i <= end; i += 1 {
        if !tile_edges[{i, h2[0].y}] {
            if !inside {
                if !scanned {
                    if scan_y({i, h2[0].y}, tile_edges) {
                        inside = true
                        scanned = true
                    } else {
                        return false
                    }
                } else {
                    return false
                }
            }
        } else {
            inside = false
        }
    }
    return true
}
check_vertical :: proc(v1, v2: [2]Int2, tile_edges: ^map[Int2]bool) -> bool {
    st, end: int
    inside, scanned: bool
    if v1[0].y < v1[1].y {
        st = v1[0].y
        end = v1[1].y
    } else {
        st = v1[1].y
        end = v1[0].y
    }
    for i := st; i <= end; i += 1 {
        if !tile_edges[{v1[0].x, i}] {
            if !inside {
                if !scanned {
                    if scan_x({v1[0].x, i}, tile_edges) {
                        inside = true
                        scanned = true
                    } else {
                        return false
                    }
                } else {
                    return false
                }
            }
        } else {
            inside = false
        }
    }
    if v2[0].y < v2[1].y {
        st = v2[0].y
        end = v2[1].y
    } else {
        st = v2[1].y
        end = v2[0].y
    }
    inside = false
    scanned = false
    for i := st; i <= end; i += 1 {
        if !tile_edges[{v2[0].x, i}] {
            if !inside {
                if !scanned {
                    if scan_x({v2[0].x, i}, tile_edges) {
                        inside = true
                        scanned = true
                    } else {
                        return false
                    }
                } else {
                    return false
                }
            }
        } else {
            inside = false
        }
    }
    return true
}
// Scan left & right along the x axis for tile edge.
// Return true if an edge is found for both directions.
scan_x :: proc(c: Int2, tile_edges: ^map[Int2]bool) -> bool {
    l, r: bool
    for key in tile_edges {
        if key.y == c.y {
            if key.x >= c.x {
                r = true
            } else if key.x <= c.x {
                l = true
            }
            if r && l { return true }
        }
    }
    return false
}
// Scan up & down the y axis for tile edge.
// Return true if an edge is found for both directions.
scan_y :: proc(c: Int2, tile_edges: ^map[Int2]bool) -> bool {
    u, d: bool
    for key in tile_edges {
        if key.x == c.x {
            if key.y >= c.y {
                d = true
            } else if key.y <= c.y {
                u = true
            }
        }
        if u && d { return true }
    }
    return false
}
connect_tiles :: proc(from, to: Int2, tile_edges: ^map[Int2]bool) {
    if from.x == to.x {
        if from.y < to.y {
            for i in from.y ..< to.y {
                tile_edges[{from.x, i}] = true
            }
        } else {
            for i := from.y; i >= to.y; i -= 1 {
                tile_edges[{from.x, i}] = true
            }
        }
    } else {
        if from.x < to.x {
            for i in from.x ..< to.x {
                tile_edges[{i, from.y}] = true
            }
        } else {
            for i := from.x; i >= to.x; i -= 1 {
                tile_edges[{i, from.y}] = true
            }
        }
    }
}
find_area :: proc(c1, c2: Int2) -> int {
    w, h: int
    if c1.x >= c2.x {
        w = c1.x - c2.x
    } else {
        w = c2.x - c1.x
    }
    if c1.y >= c2.y {
        h = c1.y - c2.y
    } else {
        h = c2.y - c1.y
    }
    w += 1
    h += 1
    return w * h
}
sort_squares :: proc(main: ^[]Square) {
    leng := len(main)
    if leng > 1 {
        mid := leng / 2
        left := slice.clone(main[:mid])
        right := slice.clone(main[mid:])
        sort_squares(&left)
        sort_squares(&right)
        merge_squares(&left, &right, main)
        delete(left)
        delete(right)
    }
}
merge_squares :: proc(left: ^[]Square, right: ^[]Square, main: ^[]Square) {
    l_len := len(left)
    r_len := len(right)
    l, r, m: int
    for l < l_len && r < r_len {
        if left[l].area > right[r].area {
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
// Only usful for example/test inputs. Still neat though.
print_grid :: proc(c1, c2: [2]Int2, tile_edges: ^map[Int2]bool, list: ^[]Int2) {
    reset := "\e[m"
    red := "\e[31m"
    ylw := "\e[33m"
    grn := "\e[32m"
    blu := "\e[34m"
    _, max := find_bounds(tile_edges)
    w, h: int
    w = max.x + 2
    h = max.y + 1
    fmt.println()
    for y in 0 ..< h {
        for x in 0 ..< w {
            if c1[0] == {x, y} || c1[1] == {x, y} {
                fmt.printf("%sX", red)
            } else if c2[0] == {x, y} || c2[1] == {x, y} {
                fmt.printf("%sO", blu)
            } else if tile_edges[{x, y}] {
                pos: Int2 = {x, y}
                is_x: bool
                for v in list {
                    if v == pos {
                        is_x = true
                        break
                    }
                }
                if is_x {
                    fmt.printf("%sX", grn)
                } else {
                    fmt.printf("%s#", grn)
                }
            } else if in_tile_map({x, y}, tile_edges) {
                fmt.printf("%s.", grn)
            } else {
                fmt.printf("%s.", ylw)
            }
            fmt.printf("%s", reset)
        }
        fmt.println(y)
    }
    fmt.println()
}
// Takes an x,y coordinate & return true if they are within the tile edges.
in_tile_map :: proc(corner: Int2, tile_edges: ^map[Int2]bool) -> bool {
    pass: bool
    if tile_edges[corner] {
        pass = true
    } else {
        if scan_x(corner, tile_edges) && scan_y(corner, tile_edges) {
            pass = true
        }
    }
    if pass { return true }
    return false
}
// Return the x & y min-max of tiles.
find_bounds :: proc(tile_edges: ^map[Int2]bool) -> (Int2, Int2) {
    x_max, y_max: int
    x_min := 9999999999
    y_min := x_min
    for key in tile_edges {
        if key.x > x_max {
            x_max = key.x
        }
        if key.y > y_max {
            y_max = key.y
        }
        if key.x < x_min {
            x_min = key.x
        }
        if key.y < y_min {
            y_min = key.y
        }
    }
    x_max += 1
    y_max += 1
    return {x_min, y_min}, {x_max, y_max}
}
check_ok :: proc(ok: bool, loc := #caller_location) {
    if !ok {
        panic("Somthing's not ok.", loc)
    }
}
check_err :: proc(err: os.Error, loc := #caller_location) {
    if err != nil {
        fmt.eprintfln("error: %v", err)
        fmt.println("at:", loc)
        os.exit(1)
    }
}
