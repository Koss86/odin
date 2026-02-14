package day8_2025
import "core:fmt"
import "core:os"
import "core:slice"

// Return true if all have the same root.
all_in_circuit :: proc(uf_map: ^[INPUT_LEN]int) -> bool {
    r := find_root(0, uf_map)
    for i in 0 ..< INPUT_LEN {
        if find_root(i, uf_map) != r {
            return false
        }
    }
    return true
}
// Returns number of conncections of a given root.
count_connected :: proc(idx: int, uf_map: ^[INPUT_LEN]int, size: int) -> int {
    n: int
    for i in 0 ..< size {
        if find_root(i, uf_map) == idx {
            n += 1
        }
    }
    return n
}
// Return root of the given index.
find_root :: proc(find: int, uf_map: ^[INPUT_LEN]int) -> int {
    b := find
    for uf_map[b] != b {
        uf_map[b] = uf_map[uf_map[b]]
        b = uf_map[b]
    }
    return b
}
// Sorts high-low
msort_root_cons :: proc(main: ^[]int) {
    leng := len(main)
    if leng > 1 {
        mid := leng / 2
        left := slice.clone(main[:mid])
        right := slice.clone(main[mid:])
        msort_root_cons(&left)
        msort_root_cons(&right)
        l_len := len(left)
        r_len := len(right)
        l, r, m := 0, 0, 0
        for l < l_len && r < r_len {
            if left[l] > right[r] {
                main[m] = left[l]
                l += 1
            } else {
                main[m] = right[r]
                r += 1
            }
            m += 1
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
        delete(left)
        delete(right)
    }
}
// Sorts low-high
msort_cons :: proc(main: ^[]Connect) {
    leng := len(main)
    if leng > 1 {
        mid := leng / 2
        left := slice.clone(main[:mid])
        right := slice.clone(main[mid:])
        msort_cons(&left)
        msort_cons(&right)
        l_len := len(left)
        r_len := len(right)
        l, r, m := 0, 0, 0
        for l < l_len && r < r_len {
            if left[l].dist < right[r].dist {
                main[m] = left[l]
                l += 1
            } else {
                main[m] = right[r]
                r += 1
            }
            m += 1
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
        delete(left)
        delete(right)
    }
}
distance_3d :: proc(pos1: Vec3, pos2: Vec3) -> int {
    dx := pos2.x - pos1.x
    dy := pos2.y - pos1.y
    dz := pos2.z - pos1.z
    dist := (dx * dx) + (dy * dy) + (dz * dz)
    // d := f64(dist)
    // d = math.sqrt(d)
    // return int(d)
    return dist
}
check_ok :: proc(ok: bool, loc := #caller_location) {
    if !ok {
        panic("Somthing's not ok.", loc)
    }
}
check_err :: proc(err: os.Error, loc := #caller_location) {
    if err != nil {
        fmt.println("error:", err)
        panic("", loc)
    }
}
