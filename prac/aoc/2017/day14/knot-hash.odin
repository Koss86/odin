package day14_2017

import "core:fmt"
import "core:os"
import "core:strconv"
import "core:strings"

make_sparse_hash :: proc(size := 256) -> []u8 {
    hash := make([]u8, size)
    for i in 0 ..< size {
        hash[i] = u8(i)
    }
    return hash
}
make_key :: proc(base: []u8, add: int) -> []u8 {
    buf: [3]u8
    suffix := [?]u8{17, 31, 73, 47, 23}
    str_num := strconv.write_int(buf[:], i64(add), 10)
    l1 := len(base)
    l2 := len(str_num)
    l3 := len(suffix)
    lT := l1 + l2 + l3
    key := make([]u8, lT)
    copy_slice(key, base)
    for i, j in l1 ..< lT - l3 {
        key[i] = str_num[j]
    }
    for i, j in l1 + l2 ..< lT {
        key[i] = suffix[j]
    }
    return key
}
parse_sparse :: proc(key: []u8, sparse_hash: ^[]u8, size := 256) {
    cur_pos, skip: int
    for _ in 0 ..< 64 {
        for leng in key {
            reverse := true
            if leng < 2 {
                reverse = false
            }
            if reverse {
                end_idx := (cur_pos + int(leng) - 1) % size
                reverse_sequence(sparse_hash, leng, cur_pos, end_idx, size)
            }
            cur_pos = (cur_pos + int(leng) + skip) % size
            skip += 1
        }
    }
}
reverse_sequence :: proc(sparse_hash: ^[]u8, leng: u8, st, end, size: int) {
    l_pos := st
    r_pos := end
    if st < end {
        for _ in 0 ..< leng / 2 {
            tmp := sparse_hash[l_pos]
            sparse_hash[l_pos] = sparse_hash[r_pos]
            sparse_hash[r_pos] = tmp
            l_pos += 1
            r_pos -= 1
        }
    } else {
        for _ in 0 ..< leng / 2 {
            tmp := sparse_hash[l_pos]
            sparse_hash[l_pos] = sparse_hash[r_pos]
            sparse_hash[r_pos] = tmp
            if l_pos == size - 1 {
                l_pos = 0
            } else {
                l_pos += 1
            }
            if r_pos == 0 {
                r_pos = size - 1
            } else {
                r_pos -= 1
            }
        }
    }
}
make_dense_hash :: proc(sparse_hash: []u8, size := 16) -> []u8 {
    st: int
    end := size
    dense_hash := make([]u8, size)
    for i in 0 ..< size {
        dense_hash[i] = dense_hash_byte(sparse_hash[st:end], size)
        st += size
        end += size
    }
    return dense_hash
}
dense_hash_byte :: proc(hash: []u8, size: int) -> u8 {
    h := hash[0] ~ hash[1]
    for i in 2 ..< size {
        h = h ~ hash[i]
    }
    return h
}
dense_hash_bin_str :: proc(dense_hash: []u8) -> string {
    bin_str_arr: [dynamic]string
    defer {
        for s in bin_str_arr { delete(s) }
        delete(bin_str_arr)
    }
    for b in dense_hash {
        str := fmt.aprintf("%8b", b)
        append(&bin_str_arr, str)
    }
    bin_str, err := strings.concatenate(bin_str_arr[:])
    check_err(err)
    return bin_str
}
dense_hash_hex_str :: proc(dense_hash: []u8) -> string {
    hex_str_arr: [dynamic]string
    defer {
        for s in hex_str_arr { delete(s) }
        delete(hex_str_arr)
    }
    for b in dense_hash {
        str := fmt.aprintf("%2x", b)
        append(&hex_str_arr, str)
    }
    hex_str, err := strings.concatenate(hex_str_arr[:])
    check_err(err)
    return hex_str
}
check_err :: proc(err: os.Error, loc := #caller_location) {
    if err != nil {
        fmt.printfln("Error: %v - %v", err, loc)
        os.exit(1)
    }
}
