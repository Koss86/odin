package day13_2019

import f "core:fmt"
import "core:os"
import sc "core:strconv"
import s "core:strings"

WALL :: 1
BLOCK :: 2
PADDLE :: 3
BALL :: 4

Vec3 :: [3]int
Vec2 :: [2]int

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

Instruction :: struct {
    opcode: Opcode,
    p1:     Param,
    p2:     Param,
    p3:     Param,
    idx:    int,
    step:   int,
    rb:     int,
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

count_item :: proc(list: []Vec3, item: int) -> int {
    c: int
    for i := 0; i < len(list); i += 1 {
        if list[i][2] == item {
            c += 1
        }
    }
    return c
}

beat_game :: proc(ic: ^map[int]int) -> int {
    input, score: int
    for {
        items, s := run_intcode(ic, input)
        if s > 0 do score = s
        if count_item(items, BLOCK) == 0 do break
        ball := item_pos(items, BALL)
        pad := item_pos(items, PADDLE)
        if ball.x > pad.x {
            input = -1
        } else if ball.x < pad.x {
            input = 1
        } else {
            input = 0
        }
        delete(items)
    }
    return score
}

item_pos :: proc(list: []Vec3, item: int) -> Vec2 {
    for i := 0; i < len(list); i += 1 {
        if list[i][2] == item {
            return {list[i].x, list[i].y}
        }
    }
    return {0, 0}
}

run_intcode :: proc(ic: ^map[int]int, input: int) -> ([]Vec3, int) {
    out: int
    pos_id: Vec3
    score: int
    ins: Instruction
    pos_id_list: [dynamic]Vec3

    for {
        ins.idx += ins.step
        parse_opcode(&ins, ic^)
        switch ins.opcode {
            case .Add:
                ic[ins.p3.val] = ins.p1.val + ins.p2.val
            case .Mul:
                ic[ins.p3.val] = ins.p1.val * ins.p2.val
            case .In:
                ic[ins.p1.val] = input
            case .Out:
                out += 1
                if out == 1 {
                    pos_id[0] = ins.p1.val
                } else if out == 2 {
                    pos_id[1] = ins.p1.val
                } else {
                    if pos_id.x == -1 && pos_id.y == 0 {
                        score = ins.p1.val
                    } else {
                        pos_id[2] = ins.p1.val
                        append(&pos_id_list, pos_id)
                    }
                    out = 0
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
                return pos_id_list[:], score
        }
    }
}

parse_opcode :: proc(ins: ^Instruction, ic: map[int]int) {

    ins.p1.val = 0
    ins.p2.val = 0
    ins.p3.val = 0
    ins.p1.mode = .None
    ins.p2.mode = .None
    ins.p3.mode = .None
    ins.step = 2

    l: int
    oc_str: string
    oc_num := ic[ins.idx]
    sbuf := make([]u8, 8)
    defer delete(sbuf)

    if oc_num > 9 {
        ok: bool
        oc_str = sc.write_int(sbuf, i64(oc_num), 10)
        l = len(oc_str)
        oc_num, ok = sc.parse_int(oc_str[l - 2:])
        check_ok(ok)
    }

    ins.opcode = assign_opcode(oc_num)

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
    opcodes: []Opcode = {.Add, .Mul, .In, .Out, .Jmpt, .Jmpf, .Lt, .Eq, .RB}
    for i in 1 ..= 9 {
        if opcode == i { return opcodes[i - 1] }
    }
    if opcode == 99 do return .End
    f.printfln("opcode=%v", opcode)
    panic("INVALID OPCODE")
}

check_ok :: proc(ok: bool, loc := #caller_location) {
    if !ok do panic("Something's not ok", loc)
}

check_err :: proc(err: os.Error, loc := #caller_location) {
    if err != nil {
        f.eprintfln("Error: %v - %v", err, loc)
        os.exit(1)
    }
}
