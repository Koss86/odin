package day05_2019

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

Modes :: enum {
    Pos,
    Im,
}

Param :: struct {
    val:  int,
    mode: Modes,
}

Instruction :: struct {
    opcode:  int,
    param_1: Param,
    param_2: Param,
    param_3: Param,
}

parse_file :: proc(file: ^[]u8) -> []int {

    intcode: [dynamic]int
    str_file := string(file^)

    for str in s.split_iterator(&str_file, ",") {
        str := s.trim_right(str, "\n")
        buf, ok := sc.parse_int(str)
        check_ok(ok)
        append(&intcode, buf)
    }

    return intcode[:]
}

test_input :: proc(ic: ^[]int, input: int, print := false) {

    // 'p' points to the current Opcode.
    // 'inc_p' increments 'p' to the next Opcode.

    p, inc_p: int
    ins: Instruction

    for ins.opcode != END {

        p += inc_p

        ins, inc_p = parse_opcode(ic[p], p, ic)

        if print do print_inscruct(ins, p)

        if ins.opcode != IN {
            // If param 1 or 2 are in .Pos mode
            // get the correct value from the intcode (ic)
            if ins.param_1.mode == .Pos {
                ins.param_1.val = ic[ins.param_1.val]
            }
            if ins.opcode != OUT && ins.param_2.mode == .Pos {
                ins.param_2.val = ic[ins.param_2.val]
            }
        }

        switch ins.opcode {

            case ADD:
                ic[ins.param_3.val] = ins.param_1.val + ins.param_2.val
            case MUL:
                ic[ins.param_3.val] = ins.param_1.val * ins.param_2.val
            case IN:
                ic[ins.param_1.val] = input
            case OUT:
                if len(ic) > 50 {
                    // If using full input don't print all the 0's.
                    if ins.param_1.val != 0 {
                        f.println(ins.param_1.val)
                    }
                } else {
                    f.println(ins.param_1.val)
                }
            case JMPT:
                if ins.param_1.val != 0 {
                    p = ins.param_2.val - inc_p
                }
            case JMPF:
                if ins.param_1.val == 0 {
                    p = ins.param_2.val - inc_p
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
}

// Determine the correct opcode, parameter modes, and the correct `inc_p` value.
parse_opcode :: proc(opcode, idx: int, ic: ^[]int) -> (ins: Instruction, inc_p := 2) {

    sbuf := make([]u8, 6, context.allocator)
    oc_str := sc.write_int(sbuf, i64(opcode), 10)

    ok: bool
    nbuf: int
    l := len(oc_str)

    if l > 2 {
        nbuf, ok = sc.parse_int(oc_str[l - 2:])
        check_ok(ok)
    } else {
        nbuf, ok = sc.parse_int(oc_str)
        check_ok(ok)
    }

    ins.opcode = nbuf

    if nbuf == END do return

    ins.param_1.val = ic[idx + 1]

    if l > 2 && oc_str[l - 3] == '1' {
        ins.param_1.mode = .Im
    }

    // IN & OUT only take 1 parameter
    if ins.opcode != IN && ins.opcode != OUT {

        ins.param_2.val = ic[idx + 2]

        if l > 3 && oc_str[l - 4] == '1' {
            ins.param_2.mode = .Im
        }

        // JMP opcodes take 2 parameters, all other opcodes take 3.
        if ins.opcode == JMPT || ins.opcode == JMPF {
            inc_p = 3
        } else {
            inc_p = 4 // 3 params + opcode = 4
            ins.param_3.val = ic[idx + 3]
        }
    }

    delete(sbuf)
    return ins, inc_p
}

print_inscruct :: proc(ins: Instruction, idx: int) {

    if ins.opcode < ADD || ins.opcode > EQ && ins.opcode != END {
        f.printfln("opcode=%v\n", ins.opcode)
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
