package day04_2019

import f "core:fmt"

main :: proc() {

    valid_1, valid_2: int

    for i in MIN ..= MAX {
        if valid_password(i) {
            valid_1 += 1
        }
        if valid_password(i, part_2 = true) {
            valid_2 += 1
        }
    }

    f.println("Part 1 answer:", valid_1)
    f.println("Part 2 answer:", valid_2)
}
