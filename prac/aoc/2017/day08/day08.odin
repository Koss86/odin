package day08_2017

import "core:fmt"
import "core:os"
import "core:strconv"
import "core:strings"

Operator :: enum {
    eq, // ==
    ne, // !=
    gt, // >
    lt, // <
    ge, // >=
    le, // <=
}
Action :: enum {
    inc,
    dec,
}
Inscruction_Set :: struct {
    target_register: string,
    action:          Action,
    action_value:    int,
    eval_register:   string,
    operator:        Operator,
    eval_value:      int,
}

main :: proc() {
    file, err := os.read_entire_file_from_path("input", context.allocator)
    // file, err := os.read_entire_file_from_path("example", context.allocator)
    check_err(err)
    str_file := string(file)
    instructs: [dynamic]Inscruction_Set
    defer { delete(file); delete(instructs) }

    for line in strings.split_lines_iterator(&str_file) {
        line := line
        iteration: int
        ok: bool
        instruct_buf: Inscruction_Set

        for element in strings.split_iterator(&line, " ") {
            switch iteration {
                case 0:
                    instruct_buf.target_register = element
                case 1:
                    switch element {
                        case "inc":
                            instruct_buf.action = .inc
                        case "dec":
                            instruct_buf.action = .dec
                    }
                case 2:
                    instruct_buf.action_value, ok = strconv.parse_int(element)
                    check_ok(ok)
                case 3:
                // skip if
                case 4:
                    instruct_buf.eval_register = element
                case 5:
                    switch element {
                        case "==":
                            instruct_buf.operator = .eq
                        case "!=":
                            instruct_buf.operator = .ne
                        case ">":
                            instruct_buf.operator = .gt
                        case "<":
                            instruct_buf.operator = .lt
                        case ">=":
                            instruct_buf.operator = .ge
                        case "<=":
                            instruct_buf.operator = .le
                    }
                case 6:
                    instruct_buf.eval_value, ok = strconv.parse_int(element)
                    check_ok(ok)
            }
            iteration += 1
        }
        append(&instructs, instruct_buf)
    }

    overall_highest: int
    register_values: map[string]int
    defer delete(register_values)

    for v in instructs {
        do_action: bool
        switch v.operator {
            case .eq:
                if register_values[v.eval_register] == v.eval_value {
                    do_action = true
                }
            case .ne:
                if register_values[v.eval_register] != v.eval_value {
                    do_action = true
                }
            case .gt:
                if register_values[v.eval_register] > v.eval_value {
                    do_action = true
                }
            case .lt:
                if register_values[v.eval_register] < v.eval_value {
                    do_action = true
                }
            case .ge:
                if register_values[v.eval_register] >= v.eval_value {
                    do_action = true
                }
            case .le:
                if register_values[v.eval_register] <= v.eval_value {
                    do_action = true
                }
        }
        if do_action {
            switch v.action {
                case .inc:
                    register_values[v.target_register] += v.action_value
                case .dec:
                    register_values[v.target_register] -= v.action_value
            }

        }
        if overall_highest < register_values[v.target_register] {
            overall_highest = register_values[v.target_register]
        }
    }
    cur_highest: int
    for _, v in register_values {
        if cur_highest < v {
            cur_highest = v
        }
    }
    fmt.println("Part 1 answer:", cur_highest)
    fmt.println("Part 2 answer:", overall_highest)
}
check_ok :: proc(ok: bool, loc := #caller_location) {
    if !ok {
        panic("Somthing's not ok.", loc)
    }
}
check_err :: proc(err: os.Error, loc := #caller_location) {
    if err != nil {
        fmt.eprintfln("error: %v", err)
        fmt.println("at:", loc)
        os.exit(1)
    }
}
