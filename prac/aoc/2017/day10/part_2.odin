package day10_2017

import "core:fmt"

part_2 :: proc(file: ^[]byte) {

    input: [dynamic]u8
    defer delete(input)
    for b in file {
        if b != '\n' {
            append(&input, b)
        }
    }

    suffix: []u8 = {17, 31, 73, 47, 23}
    for b in suffix {
        append(&input, b)
    }

    list: [dynamic]u8
    defer delete(list)
    make_list_u8(&list)
    list_size := REAL

    cur_pos, skip: int
    for _ in 0 ..< 64 {
        for len in input {

            reverse := true
            end_idx: int

            if len > 1 {
                end_idx = (cur_pos + int(len) - 1) % list_size
            } else {
                reverse = false
            }

            if reverse {
                st := cur_pos
                end := end_idx
                if st < end {
                    for _ in 0 ..< len / 2 {
                        tmp := list[st]
                        list[st] = list[end]
                        list[end] = tmp
                        st += 1
                        end -= 1
                    }
                } else {
                    for _ in 0 ..< len / 2 {
                        tmp := list[st]
                        list[st] = list[end]
                        list[end] = tmp
                        if st >= list_size - 1 {
                            st = 0
                        } else {
                            st += 1
                        }
                        if end <= 0 {
                            end = list_size - 1
                        } else {
                            end -= 1
                        }
                    }
                }
            }
            cur_pos = (cur_pos + int(len) + skip) % list_size
            skip += 1
        }
    }

    list_idx: int
    dense_hash: [dynamic]u8
    defer delete(dense_hash)

    for _ in 0 ..< 16 {
        hash_buf: [dynamic]u8
        defer delete(hash_buf)
        for _ in 0 ..< 16 {
            append(&hash_buf, list[list_idx])
            list_idx += 1
        }
        append(&dense_hash, generate_dense_hash_byte(hash_buf[:]))
    }

    fmt.printf("Part 2 answer: ")
    for byte in dense_hash {
        fmt.printf("%2x", byte)
    }
    fmt.print("\n")
}
generate_dense_hash_byte :: proc(hash_buf: []u8) -> u8 {
    l := len(hash_buf)
    h := hash_buf[0] ~ hash_buf[1]
    for i in 2 ..< l {
        h = h ~ hash_buf[i]
    }
    return h
}
// Will print out current sequence being reversed, while highlighting the two
// elements that are currently being swapped.
print_sequence_u8 :: proc(st, end, pos_left, pos_right: int, list: []u8) {
    if st < end {
        for i in st ..= end {
            switch i {
                case pos_left:
                    fmt.printf("\e[32m%v\e[m ", list[i])
                case pos_right:
                    fmt.printf("\e[31m%v\e[m ", list[i])
                case:
                    fmt.printf("%v ", list[i])
            }
        }
    } else {
        size := len(list)
        for i in st ..< size {
            switch i {
                case pos_left:
                    fmt.printf("\e[32m%v\e[m ", list[i])
                case pos_right:
                    fmt.printf("\e[31m%v\e[m ", list[i])
                case:
                    fmt.printf("%v ", list[i])
            }
        }
        for i in 0 ..= end {
            switch i {
                case pos_left:
                    fmt.printf("\e[32m%v\e[m ", list[i])
                case pos_right:
                    fmt.printf("\e[31m%v\e[m ", list[i])
                case:
                    fmt.printf("%v ", list[i])
            }
        }
    }
    fmt.print("\n")
}
make_list_u8 :: proc(list: ^[dynamic]u8) {
    for i in 0 ..< REAL {
        append(list, u8(i))
    }
}
