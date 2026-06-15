package day08_2019

import f "core:fmt"
import "core:os"

main :: proc() {
    file, err := os.read_entire_file("input", context.allocator)
    check_err(err)

    image := parse_input(&file, 25, 6)
    delete(file)

    print_examples()

    idx := layer_least_n(image, 0)
    ans := mul_layer(image[idx], 1, 2)
    f.println("Part 1 answer:", ans)

    f.printf("Part 2 answer:\n%s", decode_image(image, 25, 6))
}
