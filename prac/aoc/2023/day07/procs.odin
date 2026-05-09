package day07_2023

import f "core:fmt"
import "core:os"
import sl "core:slice"
import sc "core:strconv"
import s "core:strings"

HAND_TYPES :: 7

Hand_Type :: enum {
    High_Card,
    One_Pair,
    Two_Pair,
    Three_Of_Kind,
    Full_House,
    Four_Of_Kind,
    Five_Of_Kind,
}

Player :: struct {
    bid:  int,
    hand: []u8,
    type: Hand_Type,
}

Hands :: [][]Player

parse_input :: proc(file: ^[]u8) -> Hands {

    plyr_buf: Player
    buf: [dynamic]u8
    dyn_arrs: [HAND_TYPES][dynamic]Player

    for r in file {
        if r == ' ' {
            plyr_buf.hand = buf[:]
            plyr_buf.type = get_hand_type(buf[:])
            buf = {}
            continue

        } else if r == '\n' {
            n, ok := sc.parse_int(string(buf[:]))
            check_ok(ok)
            plyr_buf.bid = n
            switch plyr_buf.type {
                case .High_Card:
                    append(&dyn_arrs[0], plyr_buf)
                case .One_Pair:
                    append(&dyn_arrs[1], plyr_buf)
                case .Two_Pair:
                    append(&dyn_arrs[2], plyr_buf)
                case .Three_Of_Kind:
                    append(&dyn_arrs[3], plyr_buf)
                case .Full_House:
                    append(&dyn_arrs[4], plyr_buf)
                case .Four_Of_Kind:
                    append(&dyn_arrs[5], plyr_buf)
                case .Five_Of_Kind:
                    append(&dyn_arrs[6], plyr_buf)
            }

            delete(buf)
            buf = make([dynamic]u8)
            continue
        }
        append(&buf, r)
    }
    delete(buf)

    players := make(Hands, HAND_TYPES)
    for v, i in dyn_arrs {
        players[i] = v[:]
    }
    return players
}

// Return the highest value hand for `h`.
get_hand_type :: proc(h: []u8) -> Hand_Type {

    if of_kind_or_pair(5, h) {
        return .Five_Of_Kind

    } else if of_kind_or_pair(4, h) {
        return .Four_Of_Kind

    } else if of_kind_or_pair(3, h) && of_kind_or_pair(1, h) {
        return .Full_House

    } else if of_kind_or_pair(3, h) {
        return .Three_Of_Kind

    } else if of_kind_or_pair(2, h) {
        return .Two_Pair

    } else if of_kind_or_pair(1, h) {
        return .One_Pair
    }
    return .High_Card
}

// Check for `n` pairs/of a kind in `h`.
of_kind_or_pair :: proc(n: int, h: []u8) -> bool {

    mapped: map[u8]bool
    pairs: [dynamic]int
    defer delete(pairs)
    l := len(h)

    for i in 0 ..< l - 1 {
        ct: int

        if mapped[h[i]] {
            continue

        } else {
            mapped[h[i]] = true
            for j in i + 1 ..< l {
                if h[i] == h[j] {
                    ct += 1
                }
            }
            if ct > 0 {
                if ct > 1 {
                    ct += 1
                }
                append(&pairs, ct)
            }
        }
    }
    delete(mapped)

    if n != 2 {
        for v in pairs {
            if v == n {
                return true
            }
        }
    } else {
        ct: int
        for v in pairs {
            if v == 1 {
                ct += 1
            }
            if ct == 2 {
                return true
            }
        }
    }
    return false
}

// Sort low-high based off of card ranks.
// Set `wild` to true to use wild card rankings.
sort_player_hands :: proc(players: ^Hands, wild := false) {
    for i in 0 ..< HAND_TYPES {
        sort(&players[i], wild = wild)
    }
}

sort :: proc(list: ^[]Player, wild := false) {
    l := len(list)
    if l > 1 {
        mid := l / 2
        left := sl.clone(list[:mid])
        right := sl.clone(list[mid:])
        sort(&left, wild = wild)
        sort(&right, wild = wild)
        merge(&left, &right, list, wild = wild)
        delete(left)
        delete(right)
    }
}

merge :: proc(left: ^[]Player, right: ^[]Player, main: ^[]Player, wild := false) {

    r_map := card_ranks(wild = wild)
    l_len := len(left)
    r_len := len(right)
    l, r, m, i: int

    for l < l_len && r < r_len {

        lv := r_map[left[l].hand[i]]
        rv := r_map[right[r].hand[i]]

        if lv == rv {
            i += 1

        } else if lv < rv {
            main[m] = left[l]
            l += 1
            m += 1
            i = 0

        } else {
            main[m] = right[r]
            r += 1
            m += 1
            i = 0
        }
    }
    for l < l_len {
        main[m] = left[l]
        l += 1
        m += 1
    }
    for r < r_len {
        main[m] = right[r]
        r += 1
        m += 1
    }
    delete(r_map)
}

card_ranks :: proc(wild := false) -> (map_: map[u8]int) {
    if wild {
        map_['J'] = 1
        map_['2'] = 2
        map_['3'] = 3
        map_['4'] = 4
        map_['5'] = 5
        map_['6'] = 6
        map_['7'] = 7
        map_['8'] = 8
        map_['9'] = 9
        map_['T'] = 10
    } else {
        map_['2'] = 1
        map_['3'] = 2
        map_['4'] = 3
        map_['5'] = 4
        map_['6'] = 5
        map_['7'] = 6
        map_['8'] = 7
        map_['9'] = 8
        map_['T'] = 9
        map_['J'] = 10
    }
    map_['Q'] = 11
    map_['K'] = 12
    map_['A'] = 13
    return map_
}

calculate_winnings :: proc(players: Hands) -> (winnings: int) {
    cur_rank := 1
    for hands in players {
        for plyr in hands {
            winnings += cur_rank * plyr.bid
            cur_rank += 1
        }
    }
    return winnings
}

// Reorganize and upgrade hands that contain jokers.
jokers_wild :: proc(players: ^Hands) {

    dyn_arrs: [HAND_TYPES][dynamic]Player

    for hands in players {
        for plyr in hands {
            plyr := plyr
            plyr.type = upgrade_hand(plyr)
            switch plyr.type {
                case .High_Card:
                    append(&dyn_arrs[0], plyr)
                case .One_Pair:
                    append(&dyn_arrs[1], plyr)
                case .Two_Pair:
                    append(&dyn_arrs[2], plyr)
                case .Three_Of_Kind:
                    append(&dyn_arrs[3], plyr)
                case .Full_House:
                    append(&dyn_arrs[4], plyr)
                case .Four_Of_Kind:
                    append(&dyn_arrs[5], plyr)
                case .Five_Of_Kind:
                    append(&dyn_arrs[6], plyr)
            }
        }
    }

    new := make(Hands, HAND_TYPES)
    for v, i in dyn_arrs {
        new[i] = v[:]
    }
    for v in players {
        delete(v)
    }
    delete(players^)
    players^ = new
}

// Determine new hand type based on the current hand type.
upgrade_hand :: proc(plyr: Player) -> Hand_Type {

    if plyr.type == .Five_Of_Kind || !s.contains_rune(string(plyr.hand[:]), 'J') {
        // If hand is a Five of a kind or has no 'J', no upgrade is possible.
        return plyr.type
    }
    plyr := plyr
    #partial switch plyr.type {
        case .High_Card:
            plyr.type = .One_Pair
        case .One_Pair:
            plyr.type = .Three_Of_Kind
        case .Two_Pair:
            if count_jokers(plyr.hand) > 1 {
                plyr.type = .Four_Of_Kind
            } else {
                plyr.type = .Full_House
            }
        case .Three_Of_Kind:
            plyr.type = .Four_Of_Kind
        case .Full_House:
            plyr.type = .Five_Of_Kind
        case .Four_Of_Kind:
            plyr.type = .Five_Of_Kind
    }
    return plyr.type
}

count_jokers :: proc(h: []u8) -> (ct: int) {
    for r in h {
        if r == 'J' {
            ct += 1
        }
    }
    return ct
}

struct_len :: proc(players: Hands) -> (l: int) {
    for hands in players {
        l += len(hands)
    }
    return l
}

print_num_of_hands_in_type :: proc(players: Hands) {
    for hands, i in players {
        l := len(hands)
        if l > 0 {
            type := players[i][0].type
            f.printfln("There is %v hand(s) with %v", l, type)
        } else {
            f.println("Empty.")
        }
    }
}

print_hands :: proc(players: Hands) {
    t := struct_len(players)
    for hands in players {
        ct: int
        f.println("\n", hands[0].type, sep = "")
        for plyr in hands {
            if ct < 10 {
                f.printf("%s ", plyr.hand)
                ct += 1
            } else {
                f.printfln("%s ", plyr.hand)
                ct = 0
            }
        }
    }
    f.println()
}

check_ok :: proc(ok: bool, loc := #caller_location) {
    if !ok { panic("Something's not ok", loc) }
}

check_err :: proc(err: os.Error, loc := #caller_location) {
    if err != nil {
        f.printfln("Error: %v - %v", err, loc)
        os.exit(1)
    }
}
