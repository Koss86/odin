package day07_2019

import f "core:fmt"
import "core:os"
import sc "core:strconv"
import s "core:strings"

ADD :: 1
MUL :: 2
IN :: 3
OUT :: 4
JMPT :: 5
JMPF :: 6
LT :: 7
EQ :: 8
END :: 99

Instruction :: struct {
    opcode:  int,
    param_1: Param,
    param_2: Param,
    param_3: Param,
}

Param :: struct {
    val:  int,
    mode: Modes,
}

Modes :: enum {
    Pos,
    Im,
}

State :: struct {
    idx:  int,
    step: int,
    used: bool,
}

parse_file :: proc(file: []u8) -> (ic: map[int]int) {

    i: int
    str := string(file)
    for num in s.split_iterator(&str, ",") {
        nt := s.trim_right(num, "\n")
        n, ok := sc.parse_int(nt)
        check_ok(ok)
        ic[i] = n
        i += 1
    }

    return ic
}

configure_amp :: proc(intcode: map[int]int, debug := false) -> int {

    outputs: [dynamic]int
    defer delete(outputs)
    phases: []int = {0, 1, 2, 3, 4}

    for {
        output: int
        for i in 0 ..< 5 {
            state: State
            ic := clone_map(intcode)
            output, _ = run_amp(&ic, phases[i], output, &state, debug = debug)
            delete(ic)
        }
        append(&outputs, output)
        if !next_sequence(phases) do break
    }
    ans: int
    for v in outputs {
        if ans < v {
            ans = v
        }
    }

    return ans
}

configure_with_feedback :: proc(intcode: map[int]int, debug := false) -> int {

    outputs: [dynamic]int
    phases: []int = {5, 6, 7, 8, 9}

    for {

        amp_state: [5]State // A State for each intcode (ic)
        output, fin_out, opcode: int

        ic_a := clone_map(intcode)
        ic_b := clone_map(intcode)
        ic_c := clone_map(intcode)
        ic_d := clone_map(intcode)
        ic_e := clone_map(intcode)

        for opcode != END {
            for i in 0 ..< 5 {
                switch i {
                    case 0:
                        output, opcode = run_amp(
                            &ic_a,
                            phases[i],
                            output,
                            &amp_state[i],
                            debug = debug,
                        )
                    case 1:
                        output, opcode = run_amp(
                            &ic_b,
                            phases[i],
                            output,
                            &amp_state[i],
                            debug = debug,
                        )
                    case 2:
                        output, opcode = run_amp(
                            &ic_c,
                            phases[i],
                            output,
                            &amp_state[i],
                            debug = debug,
                        )
                    case 3:
                        output, opcode = run_amp(
                            &ic_d,
                            phases[i],
                            output,
                            &amp_state[i],
                            debug = debug,
                        )
                    case 4:
                        output, opcode = run_amp(
                            &ic_e,
                            phases[i],
                            output,
                            &amp_state[i],
                            debug = debug,
                        )
                        fin_out = output
                }
            }
        }
        append(&outputs, fin_out)
        delete(ic_a)
        delete(ic_b)
        delete(ic_c)
        delete(ic_d)
        delete(ic_e)
        if !next_sequence(phases[:]) do break
    }

    answer: int
    for v in outputs {
        if answer < v {
            answer = v
        }
    }

    delete(outputs)
    return answer
}

// Like the previous intcode computer but now uses the `phase` value for the first `IN` opcode,
// and it takes an `State` pointer to keep track of the current index of each amp (when ran in
// a feedback loop) & whether or not an amp has used it's phase value as an input yet.
// Then returns the input for next amp & current opcode to know when to end the feedback loop.

run_amp :: proc(
    ic: ^map[int]int,
    phase, input: int,
    state: ^State,
    debug := false,
) -> (
    output: int,
    nxt_op: int,
) {

    ins: Instruction

    for ins.opcode != END {

        state.idx += state.step

        ins, state.step = parse_opcode(ic[state.idx], state.idx, ic)

        if debug do print_inscruct(ins, state.idx)

        switch ins.opcode {

            case ADD:
                ic[ins.param_3.val] = ins.param_1.val + ins.param_2.val

            case MUL:
                ic[ins.param_3.val] = ins.param_1.val * ins.param_2.val

            case IN:
                if state.used {
                    ic[ins.param_1.val] = input
                } else {
                    ic[ins.param_1.val] = phase
                    state.used = true
                }
            case OUT:
                return ins.param_1.val, ins.opcode
            case JMPT:
                if ins.param_1.val != 0 {
                    state.idx = ins.param_2.val - state.step
                }
            case JMPF:
                if ins.param_1.val == 0 {
                    state.idx = ins.param_2.val - state.step
                }
            case LT:
                if ins.param_1.val < ins.param_2.val {
                    ic[ins.param_3.val] = 1
                } else {
                    ic[ins.param_3.val] = 0
                }
            case EQ:
                if ins.param_1.val == ins.param_2.val {
                    ic[ins.param_3.val] = 1
                } else {
                    ic[ins.param_3.val] = 0
                }

        }
    }
    return input, ins.opcode
}

parse_opcode :: proc(opcode, idx: int, ic: ^map[int]int) -> (ins: Instruction, step := 2) {

    sbuf := make([]u8, 6, context.allocator)
    defer delete(sbuf)
    opcode_str := sc.write_int(sbuf, i64(opcode), 10)

    ok: bool
    n_buf: int
    l := len(opcode_str)

    if l > 2 {
        n_buf, ok = sc.parse_int(opcode_str[l - 2:])
        check_ok(ok)
    } else {
        n_buf, ok = sc.parse_int(opcode_str)
        check_ok(ok)
    }

    ins.opcode = n_buf

    if n_buf == END do return

    ins.param_1.val = ic[idx + 1]

    if l > 2 && opcode_str[l - 3] == '1' {
        ins.param_1.mode = .Im
    }

    if ins.opcode != IN && ins.opcode != OUT {

        ins.param_2.val = ic[idx + 2]

        if l > 3 && opcode_str[l - 4] == '1' {
            ins.param_2.mode = .Im
        }

        if ins.opcode == JMPT || ins.opcode == JMPF {
            step = 3
        } else {
            step = 4
            ins.param_3.val = ic[idx + 3]
        }
    }

    if ins.opcode != IN {
        if ins.param_1.mode == .Pos {
            ins.param_1.val = ic[ins.param_1.val]
        }
        if ins.opcode != OUT && ins.param_2.mode == .Pos {
            ins.param_2.val = ic[ins.param_2.val]
        }
    }

    return ins, step
}

clone_map :: proc(m: map[int]int) -> map[int]int {
    c, e := make(map[int]int, len(m))
    check_err(e)
    for k, v in m {
        c[k] = v
    }
    return c
}

run_examples :: proc() {

    file, err := os.read_entire_file("example1", context.allocator)
    check_err(err)

    example1 := parse_file(file)
    delete(file)

    file, err = os.read_entire_file("example2", context.allocator)
    check_err(err)

    example2 := parse_file(file)
    delete(file)

    f.println("Example 1:", configure_amp(example1))
    // f.println("Example 1:", configure_amp(example1, true))
    f.println("Example 2:", configure_with_feedback(example2))
    // f.println("Example 2:", configure_with_feedback(example2, true))

    delete(example1)
    delete(example2)
}

// Honestly an AI suggested this after I asked for something better than
// the five for loops I was using to generate the unique sequence.
// Seems to work as intended but only if the list is sorted initially.
next_sequence :: proc(phases: []int) -> bool {

    leng := len(phases)
    if leng <= 1 do return false

    i := leng - 2
    for i >= 0 && phases[i] >= phases[i + 1] {
        i -= 1
    }
    if i < 0 do return false

    j := leng - 1
    for phases[j] <= phases[i] {
        j -= 1
    }

    tmp := phases[i]
    phases[i] = phases[j]
    phases[j] = tmp

    l := i + 1
    r := leng - 1
    for l < r {
        tmp = phases[l]
        phases[l] = phases[r]
        phases[r] = tmp
        l += 1
        r -= 1
    }

    return true
}

print_inscruct :: proc(ins: Instruction, idx: int) {

    if ins.opcode < ADD || ins.opcode > EQ && ins.opcode != END {
        f.printfln("opcode=%v", ins.opcode)
        panic("invalid opcode")
    }

    f.printfln("current index: %v", idx)
    f.printf("opcode: ")
    switch ins.opcode {
        case ADD:
            f.println("ADD")
        case MUL:
            f.println("MUL")
        case IN:
            f.println("IN")
        case OUT:
            f.println("OUT")
        case JMPT:
            f.println("JMPT")
        case JMPF:
            f.println("JMPF")
        case LT:
            f.println("LT")
        case EQ:
            f.println("EQ")
        case END:
            f.println("END")
    }
    f.println("param 1:", ins.param_1.val)
    f.println("mode:", ins.param_1.mode)
    f.println("param 2:", ins.param_2.val)
    f.println("mode:", ins.param_2.mode)
    f.println("param 3:", ins.param_3.val)
    f.println("mode:", ins.param_3.mode, "\n")
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
