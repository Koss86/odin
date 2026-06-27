package day11_2019

import f "core:fmt"
import "core:os"
import sc "core:strconv"
import s "core:strings"

Vec2 :: [2]int

UP :: Vec2{0, -1}
DOWN :: Vec2{0, 1}
LEFT :: Vec2{-1, 0}
RIGHT :: Vec2{1, 0}

Opcode :: enum {
    Add,
    Mul,
    In,
    Out,
    Jmpt,
    Jmpf,
    Lt,
    Eq,
    RB,
    End,
}

Instruction :: struct {
    opcode: Opcode,
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

Robot :: struct {
    pos:  Vec2,
    dir:  Vec2,
    turn: bool,
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

paint_hull :: proc(ic: ^map[int]int, input: int) {

    part1: bool
    opcode: Opcode
    hull: map[Vec2]int
    defer delete(hull)

    if input == 0 { part1 = true }

    run_intcode(ic, input, &hull)

    if part1 {
        f.println("Part 1 answer:", len(hull))
        return
    }

    f.println("Part 2 answer:")
    f.printf(decode_paint_job(hull))

}

decode_paint_job :: proc(hull: map[Vec2]int) -> string {

    upper, lower: Vec2

    for key in hull {
        if key.x > upper.x { upper.x = key.x }
        if key.y > upper.y { upper.y = key.y }
        if key.x < lower.x { lower.x = key.x }
        if key.x < lower.y { lower.y = key.y }
    }

    message: [dynamic][]int

    for y in lower.y ..= upper.y {
        row: [dynamic]int
        for x in lower.x ..< upper.x {
            append(&row, hull[{x, y}])
        }
        append(&message, row[:])
    }

    defer {
        for v in message {
            delete(v)
        }
        delete(message)
    }
    return hidden_message(message[:])
}

hidden_message :: proc(decoded: [][]int) -> string {
    bldr := s.builder_make()
    for row in decoded {
        for n in row {
            if n == 0 {
                f.sbprint(&bldr, " ")
            } else {
                s.write_rune(&bldr, rune(9608))
            }
        }
        f.sbprint(&bldr, "\n")
    }
    return s.to_string(bldr)
}

run_intcode :: proc(ic: ^map[int]int, input: int, hull: ^map[Vec2]int) {

    input := input
    ins: Instruction
    robot: Robot = { dir = UP }

    for {

        ins.idx += ins.step
        parse_opcode(&ins, ic)

        switch ins.opcode {
            case .Add:
                ic[ins.p3.val] = ins.p1.val + ins.p2.val
            case .Mul:
                ic[ins.p3.val] = ins.p1.val * ins.p2.val
            case .In:
                ic[ins.p1.val] = input
            case .Out:
                if robot.turn {
                    if ins.p1.val == 0 {
                        change_direction(&robot, 'l')
                    } else {
                        change_direction(&robot, 'r')
                    }
                    robot.turn = false
                    robot.pos += robot.dir
                    input = hull[robot.pos]
                } else {
                    hull[robot.pos] = ins.p1.val
                    robot.turn = true
                }
            case .Jmpt:
                if ins.p1.val != 0 {
                    ins.idx = ins.p2.val - ins.step
                }
            case .Jmpf:
                if ins.p1.val == 0 {
                    ins.idx = ins.p2.val - ins.step
                }
            case .Lt:
                if ins.p1.val < ins.p2.val {
                    ic[ins.p3.val] = 1
                } else {
                    ic[ins.p3.val] = 0
                }
            case .Eq:
                if ins.p1.val == ins.p2.val {
                    ic[ins.p3.val] = 1
                } else {
                    ic[ins.p3.val] = 0
                }
            case .RB:
                ins.rb += ins.p1.val
            case .End:
                return
        }
    }
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
    oc_str: string
    op_num := ic[ins.idx]
    sbuf := make([]u8, 8)
    defer delete(sbuf)

    if op_num > 9 {
        ok: bool
        oc_str = sc.write_int(sbuf, i64(op_num), 10)
        l = len(oc_str)
        op_num, ok = sc.parse_int(oc_str[l - 2:])
        check_ok(ok)
    }

    ins.opcode = assign_opcode(op_num)

    if ins.opcode == .End do return

    p1 := ic[ins.idx + 1]
    p2 := ic[ins.idx + 2]
    p3 := ic[ins.idx + 3]

    if l < 3 || oc_str[l - 3] == '0' {
        ins.p1.mode = .Pos
    } else if oc_str[l - 3] == '1' {
        ins.p1.mode = .Im
    } else {
        ins.p1.mode = .Rel
    }

    if ins.opcode != .In && ins.opcode != .Out && ins.opcode != .RB {
        if l < 4 || oc_str[l - 4] == '0' {
            ins.p2.mode = .Pos
        } else if oc_str[l - 4] == '1' {
            ins.p2.mode = .Im
        } else {
            ins.p2.mode = .Rel
        }
        if ins.opcode == .Jmpt || ins.opcode == .Jmpf {
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

    if ins.opcode == .In {
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
        if ins.opcode != .Out && ins.opcode != .RB {
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

assign_opcode :: proc(opcode: int) -> Opcode {
    switch opcode {
        case 1:
            return .Add
        case 2:
            return .Mul
        case 3:
            return .In
        case 4:
            return .Out
        case 5:
            return .Jmpt
        case 6:
            return .Jmpf
        case 7:
            return .Lt
        case 8:
            return .Eq
        case 9:
            return .RB
        case 99:
            return .End
        case:
            f.printfln("opcode=%v\n", opcode)
            panic("INVALID OPCODE")

    }
}

change_direction :: proc(robot: ^Robot, t: rune) {
    if t == 'l' {
        switch robot.dir {
            case UP:
                robot.dir = LEFT
            case DOWN:
                robot.dir = RIGHT
            case LEFT:
                robot.dir = DOWN
            case RIGHT:
                robot.dir = UP
        }
    } else {
        switch robot.dir {
            case UP:
                robot.dir = RIGHT
            case DOWN:
                robot.dir = LEFT
            case LEFT:
                robot.dir = UP
            case RIGHT:
                robot.dir = DOWN
        }
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
