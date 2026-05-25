package day02_2019

import f "core:fmt"
import "core:os"
import sl "core:slice"
import sc "core:strconv"
import s "core:strings"

ADD :: 1
MUL :: 2
END :: 99
INPUTS :: 99

parse_input :: proc(file: ^[]u8) -> []int {

    intcode: [dynamic]int
    str_file := string(file^)

    for str in s.split_iterator(&str_file, ",") {
        str := str
        str = s.trim(str, "\n")
        tmp, ok := sc.parse_int(str)
        check_ok(ok)
        append(&intcode, tmp)
    }

    return intcode[:]
}

run_intcode_main :: proc(ic: ^[]int) {

    for i := 0; i < len(ic) - 4; i += 4 {

        op_code := ic[i]

        if op_code == END do return

        val_pos := ic[i + 1]
        val1 := ic[val_pos]

        val_pos = ic[i + 2]
        val2 := ic[val_pos]

        val_pos = ic[i + 3]

        if op_code == ADD {
            ic[val_pos] = val1 + val2

        } else if op_code == MUL {
            ic[val_pos] = val1 * val2
        }
    }
}

run_intcode_p2 :: proc(intcode: []int) -> int {

    GOAL :: 19690720
    control := sl.clone(intcode)
    ic := intcode
    input_1, input_2: int

    outer: for x in 0 ..= INPUTS {

        ic[1] = input_1
        input_2 = 0

        for y in 0 ..= INPUTS {

            ic[2] = input_2

            run_intcode_main(&ic)

            if ic[0] == GOAL {
                break outer
            } else {
                reset_mem(&ic, control)
            }

            input_2 += 1
        }

        input_1 += 1
    }

    delete(control)
    return 100 * ic[1] + ic[2]
}

reset_mem :: proc(mem: ^[]int, control: []int) {

    for i in 0 ..< len(mem) {
        if i == 1 do continue
        mem[i] = control[i]
    }

}

check_ok :: proc(ok: bool, loc := #caller_location) {
    if !ok do panic("Something's not ok", loc)
}

check_err :: proc(err: os.Error, loc := #caller_location) {
    if err != nil {
        f.printfln("Error: %v - %v", err, loc)
        os.exit(1)
    }
}
