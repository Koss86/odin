package day17_2017

import "core:fmt"

main :: proc() {
    steps := 3
    lock := make([]int, 1)

    cur_pos: int
    for i in 1 ..= 2017 {
        cur_pos, lock = steps_n_insert(cur_pos, steps, i, &lock)
    }
    fmt.println("Part 1 answer:", lock[cur_pos + 1])

    sec: int
    sec_buf: int
    cur_pos = 0
    for i in 1 ..< 50_000_000 {
        cur_pos, sec_buf = track_second(cur_pos, int(steps), i)
        if sec_buf != 0 do sec = sec_buf
    }
    fmt.println("Part 2 answer:", sec)
}

steps_n_insert :: proc(cur, steps, ins: int, lock: ^[]int) -> (int, []int) {
    new_lock := make([]int, len(lock) + 1)
    nxt_pos := next_pos(cur, steps, ins)
    front := lock[:nxt_pos]
    back := lock[nxt_pos:]
    f_len := len(front)

    copy_slice(new_lock, front)
    new_lock[f_len] = ins
    copy_slice(new_lock[f_len + 1:], back)

    delete(lock^)
    return nxt_pos, new_lock[:]
}
// If nxt_pos is 1, return nxt_pos and value to be placed in lock[1].
// Otherwise, return nxt_pos and 0.
track_second :: proc(cur, steps, ins: int) -> (int, int) {
    sec: int
    nxt_pos := next_pos(cur, steps, ins)
    if nxt_pos == 1 do sec = ins
    return nxt_pos, sec
}
next_pos :: proc(cur, steps, ins: int) -> int {
    return ((cur + steps) % ins) + 1
}
