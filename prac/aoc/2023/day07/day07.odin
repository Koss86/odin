package day07_2023

import f "core:fmt"
import "core:os"

main :: proc() {
    // file, err := os.read_entire_file("input", context.allocator)
    file, err := os.read_entire_file("example", context.allocator)
    check_err(err)

    players := parse_input(&file)
    sort_player_hands(&players)

    f.println("Part 1 answer:", calculate_winnings(players))

    jokers_wild(&players)
    sort_player_hands(&players, wild = true)

    f.println("Part 2 answer:", calculate_winnings(players))
}
