package day14_2017

import "core:fmt"
import "core:os"

DISK_LEN :: 128

main :: proc() {
    file, err := os.read_entire_file("example", context.allocator)
    check_err(err)
    base_key: [dynamic]u8
    defer delete(file)
    defer delete(base_key)
    for b in file {
        if b != '\n' {
            append(&base_key, b)
        }
    }
    append(&base_key, '-')

    hashes: [DISK_LEN]string
    defer {
        for s in hashes { delete(s) }
    }
    for i in 0 ..< DISK_LEN {
        key := make_key(base_key[:], i)
        sparse_hash := make_sparse_hash()
        parse_sparse(key, &sparse_hash)
        dense_hash := make_dense_hash(sparse_hash)
        hashes[i] = dense_hash_bin_str(dense_hash)
        delete(key)
        delete(sparse_hash)
        delete(dense_hash)
    }

    set_bits: int
    uf := create_uf_map_2d(DISK_LEN, DISK_LEN)
    defer delete(uf.uf)
    defer delete(uf.rank)
    for row, r in hashes {
        for column, c in row {
            if column == '1' {
                set_bits += 1
                check_and_union_neighbors(r, c, hashes[:], &uf)
            }
        }
    }
    fmt.println("Part 1 answer:", set_bits)

    roots: int
    counted: map[[2]int]bool
    defer delete(counted)
    for r in 0 ..< DISK_LEN {
        for c in 0 ..< DISK_LEN {
            if hashes[r][c] == '1' && !counted[{r, c}] {
                counted[{r, c}] = true
                cur_id := get_idx(r, c, DISK_LEN)
                if cur_id == uf_find(cur_id, &uf) {
                    roots += 1
                }
            }
        }
    }
    fmt.println("Part 2 answer:", roots)
}
