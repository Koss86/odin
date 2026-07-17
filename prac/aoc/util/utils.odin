package utils

import "base:intrinsics"
import "core:fmt"
import "core:os"
import "core:slice"
import "core:strconv"
import "core:strings"

pattern_search_kmp :: proc(pat, str: string) -> []int {
    n := len(str)
    m := len(pat)
    lps := make([]int, m)
    result: [dynamic]int
    make_lps(pat, lps)
    i, j: int
    for i < n {
        if str[i] == pat[j] {
            i += 1
            j += 1
            if j == m {
                append(&result, i - j)
                j = lps[j - 1]
            }
        } else {
            if j != 0 {
                j = lps[j - 1]
            } else {
                i += 1
            }
        }
    }
    return result[:]
}

@(private)
make_lps :: proc(pat: string, lps: []int) {
    leng: int
    i := 1
    for i < len(pat) {
        if pat[i] == pat[leng] {
            leng += 1
            lps[i] = leng
            i += 1
        } else {
            if leng != 0 {
                leng = lps[leng - 1]
            } else {
                lps[i] = 0
                i += 1
            }
        }
    }
}

quicksort :: proc(list: []int, lo, hi: int, sort_high_low := false) {
    if lo < hi {
        p := partition(list, lo, hi, sort_high_low)
        quicksort(list, lo, p, sort_high_low)
        quicksort(list, p + 1, hi, sort_high_low)
    }
}

@(private)
partition :: proc(list: []int, lo, hi: int, sort_high_low := false) -> int {
    piviot := list[lo]
    l := lo - 1
    h := hi + 1
    for {
        for {
            l += 1
            if !sort_high_low {
                if list[l] >= piviot { break }
            } else {
                if list[l] <= piviot { break }
            }
        }
        for {
            h -= 1
            if !sort_high_low {
                if list[h] <= piviot { break }
            } else {
                if list[h] >= piviot { break }
            }
        }
        if l >= h { return h }
        t := list[l]
        list[l] = list[h]
        list[h] = t
    }
}

sort :: proc(main: []$T, sort_high_low := false) {
    if len(main) > 1 {
        mid := len(main) / 2
        left := slice.clone(main[:mid])
        right := slice.clone(main[mid:])
        sort(left, sort_high_low)
        sort(right, sort_high_low)
        merge(left, right, main, sort_high_low)
    }
}

@(private)
merge :: proc(left, right, main: []$T, sort_high_low := false) {
    l, r, m: int
    for l < len(left) && r < len(right) {
        if !sort_high_low {
            if left[l] < right[r] {
                main[m] = left[l]
                l += 1
            } else {
                main[m] = right[r]
                r += 1
            }
        } else {
            if left[l] > right[r] {
                main[m] = left[l]
                l += 1
            } else {
                main[m] = right[r]
                r += 1
            }
        }
        m += 1
    }
    for l < len(left) {
        main[m] = left[l]
        l += 1
        m += 1
    }
    for r < len(right) {
        main[m] = right[r]
        r += 1
        m += 1
    }
}

// Make an exact copy of `list`.
copy_list :: proc(
    list: []$T,
    allocator := context.allocator,
    loc := #caller_location,
) -> (
    c: []T,
) {
    if len(list) > 0 {
        err: os.Error
        c, err = make([]T, len(list), allocator, loc)
        check_err(err)
        for v, i in list {
            c[i] = v
        }
    }
    return c
}

// Make an exact copy of `m`.
copy_map :: proc(
    m: map[$T]$E,
    allocator := context.allocator,
    loc := #caller_location,
) -> map[T]E {
    c, err := make(map[T]E, len(m), allocator, loc)
    check_err(err)
    for k, v in m {
        c[k] = v
    }
    return c
}

// Reverse the elements of `list`.
reverse_list :: proc(list: []$T) {
    l, r := 0, len(list) - 1
    for l < r {
        x := list[l]
        list[l] = list[r]
        list[r] = x
        l += 1
        r -= 1
    }
}

push :: proc(x: $T, stack: ^[dynamic]T) {
    l := len(stack)
    if l < 1 {
        append(stack, x)
    } else {
        last := stack[l - 1]
        for i := l - 1; i > 0; i -= 1 {
            stack[i] = stack[i - 1]
        }
        stack[0] = x
        append(stack, last)
    }
}

pop :: proc(stack: ^[dynamic]$T, loc := #caller_location) -> T {
    if len(stack) > 0 {
        x := stack[0]
        ordered_remove(stack, 0)
        return x
    }
    panic("stack was empty", loc)
}

// Merge a list of single digit numbers into a single number.
// {1, 2, 3, 4, 5} becomes 12,345
merge_numbers :: proc(list: []$T) -> T where intrinsics.type_is_numeric(T) {
    num: T
    mul: T = 1
    for i := len(list) - 1; i >= 0; i -= 1 {
        if list[i] > 9 do return 0
        num += list[i] * mul
        mul *= 10
    }
    return num
}

next_sequence :: proc(sequence: []$T) -> bool where intrinstic.type_is_numeric(T) {

    leng := len(sequence)
    if leng <= 1 { return false }

    i := leng - 2
    for i >= 0 && sequence[i] >= sequence[i + 1] {
        i -= 1
    }
    if i < 0 { return false }

    j := leng - 1
    for sequence[j] <= sequence[i] {
        j -= 1
    }

    tmp := sequence[i]
    sequence[i] = sequence[j]
    sequence[j] = tmp

    l := i + 1
    r := leng - 1
    for l < r {
        tmp = sequence[l]
        sequence[l] = sequence[r]
        sequence[r] = tmp
        l += 1
        r -= 1
    }

    return true
}

UF :: struct {
    uf:   []int,
    rank: []int,
}

init_uf_map :: proc(uf_map: ^UF, n: int, allocator := context.allocator, loc := #caller_location) {
    uf, err := make([]int, n, allocator, loc)
    check_err(err)
    for i in 0 ..< n {
        uf[i] = i
    }
    rank: []int
    rank, err = make([]int, n, allocator, loc)
    check_err(err)
    uf_map.uf = uf
    uf_map.rank = rank
}

// Return the number elements in same group as `x`.
uf_count_connected :: proc(x: int, uf_map: ^UF) -> int {
    n: int
    len := len(uf_map.uf)
    root := uf_find(x, uf_map)
    for i in 0 ..< len {
        if root == uf_find(i, uf_map) {
            n += 1
        }
    }
    return n
}

// Return root of `x`.
uf_find :: proc(x: int, uf_map: ^UF) -> int {
    uf := uf_map.uf
    if x != uf[x] {
        uf[x] = uf_find(uf[x], uf_map)
    }
    return uf[x]
}

uf_union :: proc(x, y: int, uf_map: ^UF) {
    root_x := uf_find(x, uf_map)
    root_y := uf_find(y, uf_map)

    if root_x == root_y {
        return
    }

    uf := uf_map.uf
    rank := uf_map.rank

    if rank[root_x] < rank[root_y] {
        uf[root_x] = uf[root_y]
    } else if rank[root_x] > rank[root_y] {
        uf[root_y] = uf[root_x]
    } else {
        uf[root_y] = uf[root_x]
        rank[root_x] += 1
    }
}

check_ok :: proc(ok: bool, loc := #caller_location) {
    if !ok do panic("Something's not ok", loc)
}

check_err :: proc(err: os.Error, loc := #caller_location) {
    if err != nil {
        fmt.eprintfln("Error: %v - %v", err, loc)
        os.exit(1)
    }
}

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

@(private)
Param :: struct {
    val:  int,
    mode: Modes,
}

@(private)
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

init_intcode :: proc(file: []u8) -> (ic: map[int]int) {
    i: int
    str_file := string(file)
    for str in strings.split_iterator(&str_file, ",") {
        str := str
        str = strings.trim_right(str, "\n")
        n, ok := strconv.parse_int(str)
        check_ok(ok)
        ic[i] = n
        i += 1
    }
    return ic
}

run_intcode :: proc(ic: ^map[int]int, ins: ^Instruction, input: int) -> int {

    for {

        ins.idx += ins.step
        parse_opcode(ins, ic^)

        switch ins.opcode {

            case .Add:
                ic[ins.p3.val] = ins.p1.val + ins.p2.val
            case .Mul:
                ic[ins.p3.val] = ins.p1.val * ins.p2.val
            case .In:
                ic[ins.p1.val] = input
            case .Out:
                return ins.p1.val
            case .Jmpt:
                if ins.p1.val != 0 { ins.idx = ins.p2.val - ins.step }
            case .Jmpf:
                if ins.p1.val == 0 { ins.idx = ins.p2.val - ins.step }
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
                return 99
        }
    }
}

@(private)
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
    // defer delete(sbuf)

    if oc_num > 9 {
        ok: bool
        oc_str = strconv.write_int(sbuf, i64(oc_num), 10)
        l = len(oc_str)
        oc_num, ok = strconv.parse_int(oc_str[l - 2:])
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

@(private)
assign_opcode :: proc(opcode: int) -> Opcode {
    opcodes: []Opcode = {.Add, .Mul, .In, .Out, .Jmpt, .Jmpf, .Lt, .Eq, .RB}
    if opcode < 10 {
        for i in 1 ..= 9 {
            if opcode == i { return opcodes[i - 1] }
        }
    } else if opcode == 99 { return .End }
    fmt.printfln("INVALID OPCODE opcode=%v\nexiting", opcode)
    os.exit(1)
}

// Modified to run a queue as the input and save the previous output (answer) in ins.p1.val.
run_intcode_d17 :: proc(ic: ^map[int]int, ins: ^Instruction, queue: []u8) -> int {

    p: int
    l := len(queue)
    prev: int

    for {

        ins.idx += ins.step
        parse_opcode(ins, ic^)

        switch ins.opcode {

            case .Add:
                ic[ins.p3.val] = ins.p1.val + ins.p2.val
            case .Mul:
                ic[ins.p3.val] = ins.p1.val * ins.p2.val
            case .In:
                fmt.print(rune(queue[p]))
                ic[ins.p1.val] = int(queue[p])
                p += 1
                if p == l { return 0 }
            case .Out:
                prev = ins.p1.val
                if ins.p1.val != 99 && ins.p1.val < 255 {
                    fmt.print(rune(ins.p1.val))
                }
            // return ins.p1.val
            case .Jmpt:
                if ins.p1.val != 0 { ins.idx = ins.p2.val - ins.step }
            case .Jmpf:
                if ins.p1.val == 0 { ins.idx = ins.p2.val - ins.step }
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
                ins.p1.val = prev
                return 99
        }
    }
}

// @(private)
// print_inscruction :: proc(ins: Instruction) {
//
//     if ins.opcode < ADD || ins.opcode > RB && ins.opcode != END {
//         f.printfln("opcode=%v\n", ins.opcode)
//         panic("INVALID OPCODE")
//     }
//
//     f.printfln("current index: %v", ins.idx)
//     f.printf("opcode: ")
//     switch ins.opcode {
//         case ADD:
//             f.println("ADD")
//         case MUL:
//             f.println("MUL")
//         case IN:
//             f.println("IN")
//         case OUT:
//             f.println("OUT")
//         case JMPT:
//             f.println("JMPT")
//         case JMPF:
//             f.println("JMPF")
//         case LT:
//             f.println("LT")
//         case EQ:
//             f.println("EQ")
//         case RB:
//             f.println("RB")
//         case END:
//             f.println("END")
//     }
//     f.println("param 1:", ins.p1.val)
//     f.println("mode:", ins.p1.mode)
//     f.println("param 2:", ins.p2.val)
//     f.println("mode:", ins.p2.mode)
//     f.println("param 3:", ins.p3.val)
//     f.println("mode:", ins.p3.mode)
//     f.println("base:", ins.rb, "\n")
// }
