package day03_2023

import "core:fmt"
import "core:os"
import "core:strconv"

Found :: struct {
    up:         bool,
    down:       bool,
    left:       bool,
    right:      bool,
    up_left:    bool,
    up_right:   bool,
    down_left:  bool,
    down_right: bool,
}

check_gear :: proc(pos: [2]int, schematic: []string, n_map: ^map[[2]int]int) -> (bool, int) {
    found: Found
    adjacent_nums: int
    up, down, left, right := check_bounds(pos, len(schematic), len(schematic[0]), 1)
    if up {
        if is_number(schematic[pos.y - 1][pos.x]) {
            adjacent_nums += 1
            found.up = true
        }
        if left && !found.up {
            if is_number(schematic[pos.y - 1][pos.x - 1]) {
                adjacent_nums += 1
                found.up_left = true
            }
        }
        if right && !found.up {
            if is_number(schematic[pos.y - 1][pos.x + 1]) {
                adjacent_nums += 1
                found.up_right = true
            }
        }
    }
    if down {
        if is_number(schematic[pos.y + 1][pos.x]) {
            adjacent_nums += 1
            found.down = true
        }
        if left && !found.down {
            if is_number(schematic[pos.y + 1][pos.x - 1]) {
                adjacent_nums += 1
                found.down_left = true
            }
        }
        if right && !found.down {
            if is_number(schematic[pos.y + 1][pos.x + 1]) {
                adjacent_nums += 1
                found.down_right = true
            }
        }
    }
    if left {
        if is_number(schematic[pos.y][pos.x - 1]) {
            adjacent_nums += 1
            found.left = true
        }
    }
    if right {
        if is_number(schematic[pos.y][pos.x + 1]) {
            adjacent_nums += 1
            found.right = true
        }
    }
    if adjacent_nums == 2 {
        return true, gear_ratio(pos, found, n_map^)
    }
    return false, 0
}

gear_ratio :: proc(pos: [2]int, found: Found, n_map: map[[2]int]int) -> int {
    num1, num2: int
    if found.left {
        num1 = n_map[{pos.x - 1, pos.y}]
    }
    if found.right {
        if num1 == 0 {
            num1 = n_map[{pos.x + 1, pos.y}]
        } else {
            num2 = n_map[{pos.x + 1, pos.y}]
        }
    }
    if found.up && num2 == 0 {
        if num1 == 0 {
            num1 = n_map[{pos.x, pos.y - 1}]
        } else {
            num2 = n_map[{pos.x, pos.y - 1}]
        }
    }
    if found.down && num2 == 0 {
        if num1 == 0 {
            num1 = n_map[{pos.x, pos.y + 1}]
        } else {
            num2 = n_map[{pos.x, pos.y + 1}]
        }
    }
    if found.up_left && num2 == 0 {
        if num1 == 0 {
            num1 = n_map[{pos.x - 1, pos.y - 1}]
        } else {
            num2 = n_map[{pos.x - 1, pos.y - 1}]
        }
    }
    if found.down_left && num2 == 0 {
        if num1 == 0 {
            num1 = n_map[{pos.x - 1, pos.y + 1}]
        } else {
            num2 = n_map[{pos.x - 1, pos.y + 1}]
        }
    }
    if found.up_right && num2 == 0 {
        if num1 == 0 {
            num1 = n_map[{pos.x + 1, pos.y - 1}]
        } else {
            num2 = n_map[{pos.x + 1, pos.y - 1}]
        }
    }
    if found.down_right && num2 == 0 {
        num2 = n_map[{pos.x + 1, pos.y + 1}]
    }
    return num1 * num2
}

// Map the value of each number to its string coordinates.
map_number :: proc(pos: [2]int, leng: int, num_str: string, n_map: ^map[[2]int]int) {
    n, ok := strconv.parse_int(num_str)
    check_ok(ok)
    for i in pos.x ..< pos.x + leng {
        n_map[{i, pos.y}] = n
    }
}

is_valid_part_number :: proc(num_len: int, pos: [2]int, schematic: []string) -> bool {
    up, down, left, right := check_bounds(pos, len(schematic), len(schematic[0]), num_len)
    if up {
        for i in pos.x ..< pos.x + num_len {
            if valid_symbol(schematic[pos.y - 1][i]) do return true
        }
    }
    if down {
        for i in pos.x ..< pos.x + num_len {
            if valid_symbol(schematic[pos.y + 1][i]) do return true
        }
    }
    if left {
        if valid_symbol(schematic[pos.y][pos.x - 1]) do return true
        if up {
            if valid_symbol(schematic[pos.y - 1][pos.x - 1]) do return true
        }
        if down {
            if valid_symbol(schematic[pos.y + 1][pos.x - 1]) do return true
        }
    }
    if right {
        if valid_symbol(schematic[pos.y][pos.x + num_len]) do return true
        if up {
            if valid_symbol(schematic[pos.y - 1][pos.x + num_len]) do return true
        }
        if down {
            if valid_symbol(schematic[pos.y + 1][pos.x + num_len]) do return true
        }
    }
    return false
}

check_bounds :: proc(pos: [2]int, length, width, str_len: int) -> (up, down, left, right: bool) {
    if pos.y > 0 do up = true
    if pos.y < length - 1 do down = true
    if pos.x > 0 do left = true
    if pos.x + str_len < width - 1 do right = true
    return up, down, left, right
}

valid_symbol :: proc(x: u8) -> bool {
    if x != '.' && !is_number(x) do return true
    return false
}

number_length :: proc(x: string) -> (count: int) {
    l := len(x)
    for i in 0 ..< l {
        if is_number(x[i]) {
            count += 1
        } else {
            break
        }
    }
    return count
}

is_number :: proc(x: u8) -> bool {
    if x >= '0' && x <= '9' do return true
    return false
}

check_ok :: proc(ok: bool, loc := #caller_location) {
    if !ok do panic("Something's not ok", loc)
}

check_err :: proc(err: os.Error, loc := #caller_location) {
    if err != nil {
        fmt.printfln("Error: %v - %v", err, loc)
        os.exit(1)
    }
}
