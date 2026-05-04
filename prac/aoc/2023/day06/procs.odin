package day06_2023

import f "core:fmt"
import "core:os"
import sc "core:strconv"

parse_input_p1 :: proc(file: []u8) -> ([]int, []int) {

    time, dist: [dynamic]int
    in_num, in_time: bool
    in_time = true
    buf: [dynamic]u8

    for r in file {
        if r >= '0' && r <= '9' {
            in_num = true
        } else {
            if in_num {
                n, ok := sc.parse_int(string(buf[:]))
                check_ok(ok)
                if in_time {
                    append(&time, n)
                } else {
                    append(&dist, n)
                }
                buf = {}
                in_num = false
            }
            if r == '\n' {
                in_time = false
            }
            continue
        }
        append(&buf, r)
    }

    delete(buf)
    return time[:], dist[:]
}

parse_input_p2 :: proc(file: []u8) -> (t, d: int) {

    in_time := true
    buf: [dynamic]u8

    for r in file {
        if r >= '0' && r <= '9' {
            append(&buf, r)
        } else if r == '\n' {
            n, ok := sc.parse_int(string(buf[:]))
            check_ok(ok)
            buf = {}
            if in_time {
                t = n
                in_time = false
            } else {
                d = n
            }
        }
    }

    delete(buf)
    return t, d
}

check_ok :: proc(ok: bool, loc := #caller_location) {
    if !ok { panic("Something's not ok", loc) }
}

check_err :: proc(err: os.Error, loc := #caller_location) {
    if err != nil {
        f.printfln("Error: %v - %v", err, loc)
        os.exit(1)
    }
}
