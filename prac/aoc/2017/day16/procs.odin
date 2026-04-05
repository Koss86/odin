package day16_2017

import "core:fmt"
import "core:os"
import "core:strconv"
import "core:strings"

parse_input :: proc(file: ^[]u8) -> []Dance_Move {
    str_file := string(file^)
    dance_moves: [dynamic]Dance_Move

    for str in strings.split_iterator(&str_file, ",") {
        str := str
        if strings.contains(str, "\n") {
            str = strings.trim_right(str, "\n")
        }

        move_buf: Dance_Move
        if str[:1] == "s" {
            move_buf.move = .Spin
        } else if str[:1] == "x" {
            move_buf.move = .Exchange
        } else if str[:1] == "p" {
            move_buf.move = .Partner
        } else {
            panic("unknown move")
        }

        switch move_buf.move {
            case .Spin:
                n, ok := strconv.parse_int(str[1:])
                check_ok(ok)
                move_buf.num1 = n

            case .Exchange:
                sep := strings.index_rune(str, '/')
                if sep == -1 { panic("couldnt find sep") }
                n, ok := strconv.parse_int(str[1:sep])
                check_ok(ok)
                move_buf.num1 = n
                n, ok = strconv.parse_int(str[sep + 1:])
                check_ok(ok)
                move_buf.num2 = n

            case .Partner:
                sep := strings.index_rune(str, '/')
                if sep == -1 { panic("couldnt find sep") }
                move_buf.byte1 = u8(str[sep - 1])
                move_buf.byte2 = u8(str[sep + 1])
        }
        append(&dance_moves, move_buf)
    }
    return dance_moves[:]
}
dance :: proc(p: ^[]u8, move: Dance_Move) {
    switch move.move {
        case .Spin:
            spin(move.num1, p)
        case .Exchange:
            exchange(move.num1, move.num2, p)
        case .Partner:
            partner(move.byte1, move.byte2, p)
    }
}
spin :: proc(n: int, p: ^[]u8) {
    l := len(p)
    front := make([]u8, l - n)
    end := make([]u8, n)
    copy_slice(front, p[:l - n])
    copy_slice(end, p[l - n:])
    copy_slice(p[:n], end)
    copy_slice(p[n:], front)
    delete(front)
    delete(end)
}
exchange :: proc(x, y: int, p: ^[]u8) {
    tmp := p[x]
    p[x] = p[y]
    p[y] = tmp
}
partner :: proc(x, y: u8, p: ^[]u8) {
    x_idx := strings.index_rune(string(p[:]), rune(x))
    y_idx := strings.index_rune(string(p[:]), rune(y))
    tmp := p[x_idx]
    p[x_idx] = p[y_idx]
    p[y_idx] = tmp
}
real_or_example :: proc(l: int) -> []u8 {
    progs: []u8
    if l > 1000 {
        buf := []u8{'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p'}
        tmp := make([]u8, len(buf))
        copy_slice(tmp, buf[:])
        progs = tmp
    } else {
        buf := []u8{'a', 'b', 'c', 'd', 'e'}
        tmp := make([]u8, len(buf))
        copy_slice(tmp, buf[:])
        progs = tmp
    }
    return progs
}
check_ok :: proc(ok: bool, loc := #caller_location) {
    if !ok {
        panic("Something's not ok", loc)
    }
}
check_err :: proc(err: os.Error, loc := #caller_location) {
    if err != nil {
        fmt.printfln("Error: %v - %v", err, loc)
        os.exit(1)
    }
}
