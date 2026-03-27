package day12_2017

import "core:fmt"
import "core:os"
import "core:strconv"
import "core:strings"

INPUT_LEN :: 2000

UF :: struct {
    uf:   [dynamic]int,
    rank: [dynamic]int,
}

Villager :: struct {
    id:    int,
    pipes: [dynamic]int,
}

main :: proc() {
    file, err := os.read_entire_file_from_path("input", context.allocator)
    check_err(err)
    defer delete(file)

    villagers: [dynamic]Villager
    defer {
        for v in villagers {
            delete(v.pipes)
        }
        delete(villagers)
    }

    it: int
    str_file := string(file)

    for line in strings.split_lines_iterator(&str_file) {

        line := line
        villagers_buf: Villager

        for str in strings.split_iterator(&line, " ") {

            trimmed := strings.trim_right(str, ",")

            if it == 0 {
                n, ok := strconv.parse_int(trimmed)
                check_ok(ok)
                villagers_buf.id = n

            } else if it > 1 {
                n, ok := strconv.parse_int(trimmed)
                check_ok(ok)
                append(&villagers_buf.pipes, n)
            }
            it += 1
        }
        append(&villagers, villagers_buf)
        it = 0
    }

    uf_map: UF
    create_uf(&uf_map, INPUT_LEN)
    defer delete(uf_map.uf); delete(uf_map.rank)

    for villager in villagers {
        for pipe in villager.pipes {
            uf_union(villager.id, pipe, &uf_map)
        }
    }

    fmt.println("Part 1 answer:", count_connected(0, &uf_map))

    roots: int
    for i in 0 ..< INPUT_LEN {
        if i == uf_map.uf[i] {
            roots += 1
        }
    }

    fmt.println("Part 2 answer:", roots)
}
count_connected :: proc(x: int, uf_map: ^UF) -> int {
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
create_uf :: proc(uf_map: ^UF, n: int) {
    for i in 0 ..< n {
        append(&uf_map.uf, i)
        append(&uf_map.rank, 0)
    }
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
