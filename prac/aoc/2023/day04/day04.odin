package day04_2023

import "core:fmt"
import "core:os"

main :: proc() {
    // file, err := os.read_entire_file("input", context.allocator)
    file, err := os.read_entire_file("example", context.allocator)
    check_err(err)

    cards := parse_input(&file)
    won: [dynamic]Won
    sum: int

    for card, i in cards {

        matched, winner := check_card(card)

        if winner {
            buf: Won
            buf.idx = i
            buf.amt = matched
            append(&won, buf)
            points := 1

            for _ in 0 ..< matched - 1 {
                points = points * 2
            }

            sum += points
        }
    }
    fmt.println("Part 1 answer:", sum)

    sum = 0
    l := len(cards)
    won_slice := won[:]

    for i in 0 ..< l {
        sum += counting_cards(i, &won_slice)
    }
    fmt.println("Part 2 answer:", sum)
}
