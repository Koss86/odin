package day17_2019

import "../../util"
import f "core:fmt"
import sc "core:strconv"
import s "core:strings"

Vec2 :: [2]int

UP :: Vec2{0, -1}
DOWN :: Vec2{0, 1}
LEFT :: Vec2{-1, 0}
RIGHT :: Vec2{1, 0}

construct_image :: proc(ic: map[int]int) -> []string {

    ic := ic
    out: int
    line: [dynamic]u8
    image: [dynamic]string
    ins: util.Instruction

    for out != 99 {
        out = util.run_intcode(&ic, &ins, 0)
        r := u8(out)
        if r != '\n' {
            append(&line, r)
        } else {
            str := string(line[:])
            if len(str) > 0 { append(&image, str) }
            line = {}
        }
    }

    return image[:]
}

list_intersecs :: proc(image: []string) -> []Vec2 {

    intersecs: [dynamic]Vec2
    w, h := len(image[0]), len(image)
    dirs: [4]Vec2 = {UP, DOWN, LEFT, RIGHT}

    for y in 1 ..< h - 2 {
        for x in 1 ..< w - 2 {
            if image[y][x] != '#' { continue }
            cross := true
            pos: Vec2 = {x, y}
            for i := 0; i < 4; i += 2 {
                dir := pos + dirs[i]
                op_dir := pos + dirs[i + 1]
                if image[dir.y][dir.x] != '#' || image[op_dir.y][op_dir.x] != '#' {
                    cross = false
                    break
                }
            }
            if cross { append(&intersecs, pos) }
        }
    }
    return intersecs[:]

}

notify_robots :: proc(routine: []u8, feed: u8, ic: map[int]int) -> int {

    ic := ic
    ic[0] = 2
    out: int
    ins: util.Instruction
    out_bufr: [dynamic]u8
    defer delete(out_bufr)

    for {

        // output start image
        out = util.run_intcode(&ic, &ins, 0)
        append(&out_bufr, u8(out))

        if out == '\n' {
            str := string(out_bufr[:])
            f.print(str)
            if str == "Main:\n" {
                // input main routine
                out = util.run_intcode_d17(&ic, &ins, routine)

            } else if str == "Continuous video feed?\n" {
                for out != 99 {
                    // output end image if feed = 'n'
                    // output image for each move if feed = 'y'
                    out = util.run_intcode_d17(&ic, &ins, {feed, '\n'})
                }
                break
            }
            out_bufr = {}
        }
    }
    return ins.p1.val
}

main_routine :: proc(image: []string) -> []u8 {

    raw_path := define_route(image)
    path := format_path(raw_path)
    pats := pattern_list(raw_path)
    moves := move_patterns(path, pats)

    main_func := main_function(moves, path)
    funcs := move_functions(moves)
    routine: [dynamic]u8

    for v in main_func { append(&routine, v) }
    for func in funcs {
        for v in func {
            if v != 0 { append(&routine, v) }
        }
    }

    delete(moves)
    delete(funcs)
    delete(main_func)
    delete(raw_path)

    return routine[:]
}

main_function :: proc(moves: []string, path: string) -> []u8 {

    p: int
    main_func: [dynamic]u8
    func: []u8 = {'A', 'B', 'C'}
    lengs: []int = {len(moves[0]), len(moves[1]), len(moves[2])}

    out: for {
        for pat, i in moves {
            slc := path[p:p + lengs[i]]
            if pat != slc { continue }
            append(&main_func, func[i])
            append(&main_func, ',')
            p += lengs[i]
            if p >= len(path) { break out }
        }
    }
    l := len(main_func)
    main_func[l - 1] = '\n'
    return main_func[:]
}

move_functions :: proc(moves: []string) -> [][]u8 {

    lengs: []int = {len(moves[0]), len(moves[1]), len(moves[2])}
    funcs := make([][]u8, 3)
    funcs[0] = make([]u8, lengs[0] * 2)
    funcs[1] = make([]u8, lengs[1] * 2)
    funcs[2] = make([]u8, lengs[2] * 2)

    p: int
    for pat, i in moves {
        for j := 0; j < len(pat); j += 1 {

            second_digit: bool
            r := u8(pat[j])

            if j < len(pat) - 1 && r >= '0' && r <= '9' {
                if pat[j + 1] >= '0' && pat[j + 1] <= '9' {
                    second_digit = true
                    funcs[i][p] = r
                    p += 1
                    j += 1
                    funcs[i][p] = u8(pat[j])
                    p += 1
                }
            }
            if !second_digit {
                funcs[i][p] = r
                p += 1
            }

            funcs[i][p] = ','
            p += 1
        }
        // replace trailing comma with newline
        funcs[i][p - 1] = '\n'
        p = 0
    }

    return funcs
}

// Find which three patterns will get to the end of path.
move_patterns :: proc(path: string, pats: []string) -> []string {
    patterns: []string
    out: for a, i in pats[:len(pats) - 2] {
        for b, j in pats[i + 1:] {
            if i == j { continue }
            for c, l in pats[j + 1:] {
                if l == i || l == j { continue }
                test_pats := make([]string, 3)
                test_pats[0] = a
                test_pats[1] = b
                test_pats[2] = c
                if test_patterns(path, test_pats[:]) {
                    patterns = test_pats[:]
                    break out
                }
                delete(test_pats)
            }
        }
    }
    return patterns
}

test_patterns :: proc(path: string, pats: []string) -> bool {
    p: int
    for {
        moved: bool
        for pat in pats {
            pat_len := len(pat)
            new_pat: bool
            for i in 0 ..< pat_len {
                if path[p + i] != pat[i] {
                    new_pat = true
                    break
                }
            }
            if new_pat { continue }
            // f.println("testing:", pat, "p =", p)
            // f.println(path)
            // f.printfln("%*s^p", p, "")
            moved = true
            p += pat_len
            if p == len(path) { return true }
        }
        if !moved { return false }
    }
}

define_route :: proc(image: []string) -> []u8 {

    moved: u8
    path: [dynamic]u8
    pos, dir := pos_and_dir(image)
    scaffold := map_scaffold(image)
    turns: [4][2]Vec2 = {{LEFT, RIGHT}, {RIGHT, LEFT}, {DOWN, UP}, {UP, DOWN}}

    for {
        if scaffold[pos + dir] {
            pos += dir
            moved += 1
        } else {
            turn: [2]Vec2
            if dir == UP {
                turn = turns[0]
            } else if dir == DOWN {
                turn = turns[1]
            } else if dir == LEFT {
                turn = turns[2]
            } else if dir == RIGHT {
                turn = turns[3]
            }
            if moved > 0 { append(&path, moved) }
            moved = 0
            if scaffold[pos + turn.x] {
                dir = turn.x
                append(&path, 'L')
            } else if scaffold[pos + turn.y] {
                dir = turn.y
                append(&path, 'R')
            } else {
                break
            }
        }
    }

    return path[:]
}

map_scaffold :: proc(image: []string) -> map[Vec2]bool {
    m: map[Vec2]bool
    for row, y in image {
        for col, x in row {
            if col == '#' {
                m[{x, y}] = true
            }
        }
    }
    return m
}

pos_and_dir :: proc(image: []string) -> (pos: Vec2, dir: Vec2) {
    for row, y in image {
        for col, x in row {
            if col == '^' || col == 'v' || col == '<' || col == '>' {
                dir: Vec2
                if col == '^' {
                    dir = UP
                } else if col == 'v' {
                    dir = DOWN
                } else if col == '<' {
                    dir = LEFT
                } else {
                    dir = RIGHT
                }
                return {x, y}, dir
            }
        }
    }
    panic("Not found")
}

pattern_list :: proc(path: []u8) -> []string {

    path := format_path(path, 1)
    drectives: [dynamic]string
    for str in s.split_iterator(&path, ",") { append(&drectives, str) }
    patterns: [dynamic]string
    slc := make([]string, 5)
    seen: map[string]bool
    defer delete(seen)
    defer delete(drectives)
    // `p` is used to slice `directives` into patterns of 2-5 directives.
    // Where a directive is a turn (L or R) then the number of steps.
    p: Vec2 = {0, 2}
    p_max: Vec2 = {6, len(drectives) - 6}

    for {
        for p.y < p.x + p_max.x {
            if p.y - p.x > 1 {
                slc = drectives[p.x:p.y]
                pat_str := s.concatenate(slc)
                if !seen[pat_str] {
                    seen[pat_str] = true
                    append(&patterns, pat_str)
                }
            }
            p.y += 1
        }

        if p.x < p_max.y {
            p = {p.x + 1, p.x + 3}
        } else if p.x < len(drectives) - (p_max.x - 1) {
            p = {p.x + 1, len(drectives)}
            break
        }
    }

    for p.x < len(drectives) - 2 {
        if p.y - p.x > 1 {
            slc = drectives[p.x:p.y]
            pat_str := s.concatenate(slc)
            if !seen[pat_str] {
                seen[pat_str] = true
                append(&patterns, pat_str)
            }
        }
        p.x += 1
    }

    return patterns[:]
}

format_path :: proc(path: []u8, comma := 0) -> string {

    list: [dynamic]u8
    leng := len(path)
    sbuf := make([]u8, 2)
    defer delete(sbuf)

    for i := 0; i < leng - 1; i += 2 {
        lr := path[i]
        val := path[i + 1]
        str := sc.write_int(sbuf, i64(val), 10)
        append(&list, lr)
        if comma > 1 { append(&list, ',') }
        for _, j in str { append(&list, str[j]) }
        if comma > 0 { append(&list, ',') }
    }

    return string(list[:])
}
