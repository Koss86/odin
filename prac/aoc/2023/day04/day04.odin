package day04_2023

import "core:fmt"
import "core:os"

main :: proc() {
    // file, err := os.read_entire_file("input", context.allocator)
    file, err := os.read_entire_file("example", context.allocator)
    check_err(err)

    cards := parse_input(&file)
    sum: int
    won: map[int]bool
    matches: map[int]int

    for card, i in cards {

        matched, winner := check_card(card)

        if winner {

            points := 1
            won[i] = true
            matches[i] = matched

            for _ in 0 ..< matched - 1 {
                points = points * 2
            }

            sum += points
        }
    }
    fmt.println("Part 1 answer:", sum)

    sum = 0
    l := len(cards)

    for i in 0 ..< l {
        sum += counting_cards(i, &won, &matches)
    }
    fmt.println("Part 2 answer:", sum)
}
