package day04_2023

import "core:fmt"
import "core:os"
import "core:strconv"
import "core:strings"

Card :: struct {
    winners: [dynamic]int,
    have:    [dynamic]int,
}

Won :: struct {
    idx: int, // Index for correct card in cards[].
    amt: int, // Number of 'haves' that match 'winners'.
}

parse_input :: proc(file: ^[]u8) -> []Card {

    str_file := string(file^)
    cards: [dynamic]Card

    for line in strings.split_lines_iterator(&str_file) {

        buf: Card
        col_idx := strings.index_rune(line, ':')
        sep_idx := strings.index_rune(line, '|')
        winners := line[col_idx + 1:sep_idx]

        for num in strings.split_iterator(&winners, " ") {
            if num != "" {
                n, ok := strconv.parse_int(num)
                check_ok(ok)
                append(&buf.winners, n)
            }
        }

        have := line[sep_idx + 1:]

        for num in strings.split_iterator(&have, " ") {
            if num != "" {
                n, ok := strconv.parse_int(num)
                check_ok(ok)
                append(&buf.have, n)
            }
        }

        append(&cards, buf)
    }

    return cards[:]
}

// Return if card it's a winner and how many numbers matched.
check_card :: proc(scratcher: Card) -> (matched: int, winner: bool) {
    for h in scratcher.have {
        for w in scratcher.winners {
            if h == w {
                matched += 1
                winner = true
                break
            }
        }
    }
    return matched, winner
}

// If card is a winner, recursively search for the amount of cards it will grant.
// If not a winner, return 1 for itself.
counting_cards :: proc(cur_card: int, won: ^[]Won) -> (amt_cards: int) {

    winner: bool
    won_idx: int

    for v, i in won {
        if v.idx == cur_card {
            winner = true
            won_idx = i
            break
        }
    }

    amt_cards = 1

    if !winner do return amt_cards

    for i in 1 ..< won[won_idx].amt + 1 {
        amt_cards += counting_cards(cur_card + i, won)
    }

    return amt_cards
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
