package day16_2017

import "core:fmt"
import "core:os"

Move :: enum {
    Spin,
    Exchange,
    Partner,
}

Dance_Move :: struct {
    move:  Move,
    num1:  int,
    num2:  int,
    byte1: u8,
    byte2: u8,
}

main :: proc() {
    file, err := os.read_entire_file("input", context.allocator)
    // file, err := os.read_entire_file("example", context.allocator)
    check_err(err)
    defer delete(file)

    dance_moves := parse_input(&file)
    defer delete(dance_moves)

    programs := real_or_example(len(file))
    defer delete(programs)

    start_state := make([]u8, len(programs))
    copy_slice(start_state, programs)
    defer delete(start_state)

    for moves in dance_moves {
        p_slc := programs[:]
        dance(&p_slc, moves)
    }
    fmt.println("Part 1 answer:", string(programs[:]))

    copy_slice(programs, start_state)

    its := 1_000_000_000
    for i := 0; i < its; i += 1 {
        p_slc := programs[:]
        for moves in dance_moves {
            dance(&p_slc, moves)
        }
        if string(programs) == string(start_state) {
            cur_cycle := i + 1
            its = (its % cur_cycle) + 1
            i = 0
        }
    }
    fmt.println("Part 2 answer:", string(programs))
}

