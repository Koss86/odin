package day16_2019

import "../../util"
import f "core:fmt"
import "core:os"

main :: proc() {

    input: string
    args := os.args

    if len(args) > 1 do input = args[1]
    else do input = "example4"

    file, err := os.read_entire_file(input, context.allocator)
    util.check_err(err)

    run_examples()

    signal := parse_file(file)
    cpy := util.copy_list(signal)
    signal = fft(signal, 100)
    ans := util.merge_numbers(signal[:8])
    f.println("Part 1 answer:", ans)
    delete(signal)

    offset := util.merge_numbers(cpy[:7])
    signal = fft_scanr(cpy, 100, offset)
    ans = util.merge_numbers(signal[:8])
    f.println("Part 2 answer:", ans)
}
