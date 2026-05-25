package day04_2019

import sc "core:strconv"

LEN :: 6
MIN :: 246515 // Puzzle
MAX :: 739105 // Input

valid_password :: proc(n: int, part_2 := false) -> bool {

    buf := make([]u8, LEN, context.allocator)
    str := sc.write_int(buf, i64(n), 10)

    for i in 0 ..< LEN - 1 {
        if str[i] > str[i + 1] {
            return false
        }
    }

    for i in 0 ..< LEN - 1 {
        if str[i] == str[i + 1] {
            if part_2 {
                if valid_p2_double(str, i) {
                    return true
                }
            } else {
                return true
            }
        }
    }

    delete(buf)
    return false
}

valid_p2_double :: proc(str: string, idx: int) -> bool {

    r := str[idx]

    if idx > 0 && idx < LEN - 2 {
        if str[idx - 1] != r && str[idx + 2] != r {
            return true
        }

    } else if idx == 0 {
        if str[idx + 2] != r {
            return true
        }

    } else if idx == LEN - 2 {
        if str[idx - 1] != r {
            return true
        }
    }

    return false
}

check_ok :: proc(ok: bool, loc := #caller_location) {
    if !ok do panic("Something's not ok", loc)
}
