package day14_2017

UF_Map :: struct {
    uf:   [dynamic]int,
    rank: [dynamic]int,
}

check_and_union_neighbors :: proc(row, col: int, hashes: []string, uf_map: ^UF_Map) {
    w := len(hashes[row])
    l := len(hashes)
    cur_idx := get_idx(row, col, w)
    if row > 0 {
        if hashes[row - 1][col] == '1' {
            up_idx := get_idx(row - 1, col, w)
            uf_union(cur_idx, up_idx, uf_map)
        }
    }
    if row < l - 1 {
        if hashes[row + 1][col] == '1' {
            down_idx := get_idx(row + 1, col, w)
            uf_union(cur_idx, down_idx, uf_map)
        }
    }
    if col > 0 {
        if hashes[row][col - 1] == '1' {
            left_idx := get_idx(row, col - 1, w)
            uf_union(cur_idx, left_idx, uf_map)
        }
    }
    if col < w - 1 {
        if hashes[row][col + 1] == '1' {
            right_idx := get_idx(row, col + 1, w)
            uf_union(cur_idx, right_idx, uf_map)
        }
    }
}
get_idx :: proc(row, col, width: int) -> int {
    return row * width + col
}
create_uf_map_2d :: proc(l, w: int) -> UF_Map {
    uf: UF_Map
    for i in 0 ..< l * w {
        append(&uf.uf, i)
        append(&uf.rank, 0)
    }
    return uf
}
uf_find :: proc(x: int, uf_map: ^UF_Map) -> int {
    uf := uf_map.uf
    if x != uf[x] {
        uf[x] = uf_find(uf[x], uf_map)
    }
    return uf[x]
}
count_connected :: proc(x: int, uf_map: ^UF_Map) -> int {
    n: int
    len := len(uf_map.uf)
    root := uf_find(x, uf_map)
    for i in 0 ..< len {
        if root == uf_find(i, uf_map) {
            n += 1
        }
    }
    return n
}
uf_union :: proc(x, y: int, uf_map: ^UF_Map) {
    root_x := uf_find(x, uf_map)
    root_y := uf_find(y, uf_map)

    if root_x == root_y {
        return
    }

    uf := uf_map.uf
    rank := uf_map.rank

    if rank[root_x] < rank[root_y] {
        uf[root_x] = uf[root_y]
    } else if rank[root_x] > rank[root_y] {
        uf[root_y] = uf[root_x]
    } else {
        uf[root_y] = uf[root_x]
        rank[root_x] += 1
    }
}
