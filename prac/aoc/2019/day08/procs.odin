package day08_2019

import f "core:fmt"
import "core:os"
import sc "core:strconv"
import s "core:strings"

// Sort the input into [layers]->[rows]->[integers] with each
// layer containing `h` rows & each row `w` long.
parse_input :: proc(file: ^[]u8, w, h: int) -> [][][]int {

    str_file := string(file^)
    image: [dynamic][][]int
    layer: [dynamic][]int
    row: [dynamic]int
    x, y: int

    for i in 0 ..< len(str_file) {

        if str_file[i] == '\n' do continue

        n, ok := sc.parse_int(str_file[i:i + 1])
        check_ok(ok)
        append(&row, n)
        x += 1

        if x == w {
            append(&layer, row[:])
            row = make([dynamic]int)
            x = 0
            y += 1
            if y == h {
                append(&image, layer[:])
                layer = make([dynamic][]int)
                y = 0
            }
        }
    }

    return image[:]
}

layer_least_n :: proc(image: [][][]int, n: int) -> int {

    amts: [dynamic]int

    for layer in image {
        ct: int
        for row in layer {
            for num in row {
                if num == n {
                    ct += 1
                }
            }
        }
        append(&amts, ct)
    }

    t := amts[0]
    idx: int

    for n, i in amts {
        if t > n {
            t = n
            idx = i
        }
    }

    delete(amts)
    return idx
}

mul_layer :: proc(layer: [][]int, n1, n2: int) -> int {

    t_n1, t_n2: int

    for row in layer {
        for n in row {
            if n == n1 {
                t_n1 += 1
            } else if n == n2 {
                t_n2 += 1
            }
        }
    }

    return t_n1 * t_n2
}

// Iterate through the layers, maintaining the same xy position,
// looking for the first non 2 integer to append to `row`, then
// move to the next 'x' position. Once `row` is the length of `w`,
// append `row` to `decoded`. Then move to the next 'y' position.
// When `decoded` has `h` rows, convert the decoded integer
// arrays into the hidden message string.

decode_image :: proc(image: [][][]int, w, h: int) -> string {

    decoded := make([dynamic][]int, context.temp_allocator)
    row := make([dynamic]int, context.temp_allocator)

    for y in 0 ..< h {
        for x in 0 ..< w {
            i: int
            for image[i][y][x] == 2 {
                i += 1
            }
            append(&row, image[i][y][x])
        }
        append(&decoded, row[:])
        row = make([dynamic]int, context.temp_allocator)
    }

    defer free_all(context.temp_allocator)
    return hidden_message(decoded[:])
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


print_examples :: proc() {
    file, err := os.read_entire_file("example1", context.allocator)
    check_err(err)

    example := parse_input(&file, 3, 2)
    delete(file)

    f.println("Example 1:")
    for layer in example {
        for row in layer {
            f.println(row)
        }
        f.println()
    }
    delete(example)

    file, err = os.read_entire_file("example2", context.allocator)
    check_err(err)

    example = parse_input(&file, 2, 2)
    delete(file)

    message := decode_image(example, 2, 2)
    f.printf("Example 2:\n%s\n", message)

    delete(example)
    delete(message)
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
