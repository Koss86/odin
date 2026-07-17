package day16_2019

import "../../util"
import f "core:fmt"
import "core:math"
import "core:os"
import sc "core:strconv"

parse_file :: proc(file: []u8) -> []int {

    signal: [dynamic]int
    str_file := string(file)

    for i in 0 ..< len(str_file) {
        r := str_file[i:i + 1]
        if r == "\n" do continue
        num, ok := sc.parse_int(r)
        util.check_ok(ok)
        append(&signal, num)
    }

    return signal[:]
}

fft :: proc(input: []int, phases: int) -> []int {

    input := input
    size := len(input)
    patterns := mul_patterns(size)

    for _ in 0 ..< phases {
        output := make([]int, size)
        for pos in 0 ..< size {
            n: int
            pat := patterns[pos][1:]
            for j in 0 ..< size {
                n += input[j] * pat[j]
            }
            output[pos] = math.abs(n % 10)
        }
        delete(input)
        input = output
    }

    return input[:]
}

mul_patterns :: proc(size: int) -> [][]int {

    main := make([][]int, size)
    base_pat: []int = {0, 1, 0, -1}

    for pos in 0 ..< size {
        p: int
        pattern: [dynamic]int
        for _ in 0 ..< size + 1 {
            buff: [dynamic]int
            for _ in 0 ..< pos + 1 {
                append(&buff, base_pat[p])
            }

            if p > 2 do p = 0
            else do p += 1
            for v in buff {
                append(&pattern, v)
            }
            delete(buff)
        }
        main[pos] = pattern[:]
    }
    return main
}

fft_scanr :: proc(signal: []int, phases, offset: int) -> []int {

    expanded := expand(signal, 10_000)
    trimmed := util.copy_list(expanded[offset:])
    delete(expanded)
    size := len(trimmed)
    trimmed[size - 1] = math.abs(trimmed[size - 1] % 10)

    for _ in 0 ..< phases {
        for i := size - 2; i >= 0; i -= 1 {
            trimmed[i] = math.abs((trimmed[i] + trimmed[i + 1]) % 10)
        }
    }

    return trimmed
}

expand :: proc(list: []int, by: int) -> []int {
    new_list: [dynamic]int
    for _ in 0 ..< by {
        for v in list {
            append(&new_list, v)
        }
    }
    return new_list[:]
}

run_examples :: proc() {
    file, err := os.read_entire_file("example1", context.allocator)
    util.check_err(err)
    signal := parse_file(file)
    cleaned := fft(signal, 100)
    f.println("Example 1:", util.merge_numbers(cleaned[:8]))
    delete(file)
    delete(cleaned)

    file, err = os.read_entire_file("example2", context.allocator)
    util.check_err(err)
    signal = parse_file(file)
    cleaned = fft(signal, 100)
    f.println("Example 2:", util.merge_numbers(cleaned[:8]))
    delete(file)
    delete(cleaned)

    file, err = os.read_entire_file("example3", context.allocator)
    util.check_err(err)
    signal = parse_file(file)
    cleaned = fft(signal, 100)
    f.println("Example 3:", util.merge_numbers(cleaned[:8]))
    delete(file)
    delete(cleaned)

    file, err = os.read_entire_file("example4", context.allocator)
    util.check_err(err)
    signal = parse_file(file)
    offset := util.merge_numbers(signal[:7])
    cleaned = fft_scanr(signal, 100, offset)
    f.println("Example 4:", util.merge_numbers(cleaned[:8]))
    delete(file)
    delete(cleaned)

    file, err = os.read_entire_file("example5", context.allocator)
    util.check_err(err)
    signal = parse_file(file)
    offset = util.merge_numbers(signal[:7])
    cleaned = fft_scanr(signal, 100, offset)
    f.println("Example 5:", util.merge_numbers(cleaned[:8]))
    delete(file)
    delete(cleaned)

    file, err = os.read_entire_file("example6", context.allocator)
    util.check_err(err)
    signal = parse_file(file)
    offset = util.merge_numbers(signal[:7])
    cleaned = fft_scanr(signal, 100, offset)
    f.println("Example 6:", util.merge_numbers(cleaned[:8]))
    delete(file)
    delete(cleaned)
}
