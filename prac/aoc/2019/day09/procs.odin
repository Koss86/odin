package day09_2019

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
RB :: 9
END :: 99

Instruction :: struct {
    opcode: int,
    p1:     Param,
    p2:     Param,
    p3:     Param,
    idx:    int,
    step:   int,
    rb:     int,
}

Param :: struct {
    val:  int,
    mode: Modes,
}

Modes :: enum {
    None,
    Pos,
    Im,
    Rel,
}

parse_file :: proc(file: []u8) -> (ic: map[int]int) {

    i: int
    str_file := string(file)
    for str in s.split_iterator(&str_file, ",") {
        str := str
        str = s.trim_right(str, "\n")
        n, ok := sc.parse_int(str)
        check_ok(ok)
        ic[i] = n
        i += 1
    }

    return ic
}

intcode_computer :: proc(ic: ^map[int]int, input: int, debug := false) {

    ex_1: bool
    ins: Instruction

    if ic[2] == 204 && ic[15] == END {
        ex_1 = true
        f.printf("Example 1: ")
    }

    for ins.opcode != END {

        ins.idx += ins.step

        parse_opcode(&ins, ic)

        if debug do print_inscruction(ins)

        switch ins.opcode {

            case ADD:
                ic[ins.p3.val] = ins.p1.val + ins.p2.val
            case MUL:
                ic[ins.p3.val] = ins.p1.val * ins.p2.val
            case IN:
                ic[ins.p1.val] = input
            case OUT:
                if ex_1 {
                    f.printf("%i,", ins.p1.val)
                } else if ins.p1.val != 0 {
                    f.println(ins.p1.val)
                }
            case JMPT:
                if ins.p1.val != 0 {
                    ins.idx = ins.p2.val - ins.step
                }
            case JMPF:
                if ins.p1.val == 0 {
                    ins.idx = ins.p2.val - ins.step
                }
            case LT:
                if ins.p1.val < ins.p2.val {
                    ic[ins.p3.val] = 1
                } else {
                    ic[ins.p3.val] = 0
                }
            case EQ:
                if ins.p1.val == ins.p2.val {
                    ic[ins.p3.val] = 1
                } else {
                    ic[ins.p3.val] = 0
                }
            case RB:
                ins.rb += ins.p1.val
        }
    }
    if ex_1 do f.println()
}

parse_opcode :: proc(ins: ^Instruction, ic: ^map[int]int) {

    ins.p1.val = 0
    ins.p2.val = 0
    ins.p3.val = 0
    ins.p1.mode = .None
    ins.p2.mode = .None
    ins.p3.mode = .None
    ins.step = 2

    l: int
    ok: bool
    oc_str: string
    opcode := ic[ins.idx]
    sbuf := make([]u8, 8)
    defer delete(sbuf)

    if opcode > 9 {
        oc_str = sc.write_int(sbuf, i64(opcode), 10)
        l = len(oc_str)
        ins.opcode, ok = sc.parse_int(oc_str[l - 2:])
        check_ok(ok)
    } else {
        ins.opcode = opcode
    }

    if ins.opcode == END do return

    p1 := ic[ins.idx + 1]
    p2 := ic[ins.idx + 2]
    p3 := ic[ins.idx + 3]

    // Assign a mode to param 1.
    if l < 3 || oc_str[l - 3] == '0' {
        ins.p1.mode = .Pos
    } else if oc_str[l - 3] == '1' {
        ins.p1.mode = .Im
    } else {
        ins.p1.mode = .Rel
    }

    // Assign a mode to param 2 then a mode & value to param 3 if there is one.
    // And update .step if there is more than 1 parameter.
    if ins.opcode != IN && ins.opcode != OUT && ins.opcode != RB {

        if l < 4 || oc_str[l - 4] == '0' {
            ins.p2.mode = .Pos
        } else if oc_str[l - 4] == '1' {
            ins.p2.mode = .Im
        } else {
            ins.p2.mode = .Rel
        }

        if ins.opcode == JMPT || ins.opcode == JMPF {

            ins.step = 3

        } else {

            if l < 5 || oc_str[l - 5] == '0' {
                ins.p3.val = p3
                ins.p3.mode = .Pos
            } else {
                ins.p3.val = p3 + ins.rb
                ins.p3.mode = .Rel
            }

            ins.step = 4
        }
    }

    // Assign param 1 & 2 values
    if ins.opcode == IN {

        // Special case for `IN` since it is the only opcode
        // that uses param 1 to write into memory like param 3.

        if ins.p1.mode == .Pos {
            ins.p1.val = p1
        } else {
            ins.p1.val = p1 + ins.rb
        }

    } else {

        if ins.p1.mode == .Pos {
            ins.p1.val = ic[p1]
        } else if ins.p1.mode == .Im {
            ins.p1.val = p1
        } else if ins.p1.mode == .Rel {
            ins.p1.val = ic[p1 + ins.rb]
        }

        if ins.opcode != OUT && ins.opcode != RB {
            if ins.p2.mode == .Pos {
                ins.p2.val = ic[p2]
            } else if ins.p2.mode == .Im {
                ins.p2.val = p2
            } else if ins.p2.mode == .Rel {
                ins.p2.val = ic[p2 + ins.rb]
            }
        }
    }
}

run_examples :: proc() {

    file, err := os.read_entire_file("example1", context.allocator)
    check_err(err)
    example := parse_file(file)
    delete(file)

    intcode_computer(&example, 0)
    delete(example)

    file, err = os.read_entire_file("example2", context.allocator)
    check_err(err)
    example = parse_file(file)
    delete(file)

    f.printf("Example 2: ")
    intcode_computer(&example, 0)
    delete(example)

    file, err = os.read_entire_file("example3", context.allocator)
    example = parse_file(file)
    delete(file)

    f.printf("Example 3: ")
    intcode_computer(&example, 0)
    delete(example)
}

print_inscruction :: proc(ins: Instruction) {

    if ins.opcode < ADD || ins.opcode > RB && ins.opcode != END {
        f.printfln("opcode=%v\n", ins.opcode)
        panic("INVALID OPCODE")
    }

    f.printfln("current index: %v", ins.idx)
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
        case RB:
            f.println("RB")
        case END:
            f.println("END")
    }
    f.println("param 1:", ins.p1.val)
    f.println("mode:", ins.p1.mode)
    f.println("param 2:", ins.p2.val)
    f.println("mode:", ins.p2.mode)
    f.println("param 3:", ins.p3.val)
    f.println("mode:", ins.p3.mode)
    f.println("base:", ins.rb, "\n")
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
