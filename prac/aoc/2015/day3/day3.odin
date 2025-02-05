package day3
import "core:fmt"
import "core:os"
import strs "core:strings"
Vec2 :: [2] int
UP :: Vec2  { 0, 1 }
DOWN :: Vec2 { 0, -1 }
LEFT :: Vec2 { -1, 0 }
RIGHT :: Vec2  { 1, 0 }
SANTA :: 0
ROBO :: 1

main :: proc() {

    part := 2   // 1 = day 3 part 1. 2 = day 3 part 2.

    file := "../inputs/input3.txt"
    buff, ok := os.read_entire_file(file)
    if !ok {
        fmt.eprintln("Unable to read file")
        return 
    }
    defer delete(buff)

    santa_visits := make([dynamic] Vec2)  // total inputs 8192
    defer delete_dynamic_array(santa_visits)

    santa_pos: Vec2
    robo_pos: Vec2
    move: Vec2
    leng := len(buff)

    if part == 1 {

        for i in 0..<leng {
            
            dir := buff[i]
            if dir == '^' {
                move = UP
            } else if dir == 'v' {
                move = DOWN
            } else if dir == '<' {
                move = LEFT
            } else if dir == '>' {
                move = RIGHT
            }
            santa_pos += move
            append(&santa_visits, santa_pos)
        }

        pruned := prune_list(santa_visits[:])
        leng = len(pruned)
        fmt.printf("%v Houses got at lease one present!\n", leng+1)

    } else if part == 2 {

        turn: int 
        robo_visits := make([dynamic] Vec2)
        defer delete_dynamic_array(robo_visits)

        for i in 0..<leng {
            dir := buff[i]
            if dir == '^' {
                move = UP
            } else if dir == 'v' {
                move = DOWN
            } else if dir == '<' {
                move = LEFT
            } else if dir == '>' {
                move = RIGHT
            }
            if turn == SANTA {
                santa_pos += move
                append(&santa_visits, santa_pos)
                turn = ROBO
            } else if turn == ROBO {
                robo_pos += move
                append(&robo_visits, robo_pos)
                turn = SANTA
            }
        }

        robo_pruned := prune_list(robo_visits[:])
        santa_pruned := prune_list(santa_visits[:])
        unique := make([dynamic] Vec2)
        for i in 0..<len(santa_pruned) {
            if !if_found(robo_pruned[:], santa_pruned[i]) {
                append(&unique, santa_pruned[i])
            }
        }
        fmt.printfln("%v Houses got at lease one present!", len(unique)+len(robo_pruned))
    } else {
        fmt.println("Error. Set part variable to 1 or 2.")
    }
}

prune_list :: proc(list: [] Vec2) -> [] Vec2 {
    pruned := make([dynamic] Vec2, context.allocator)
    leng := len(list)

    for i in 0..<leng {
        tmp := list[i]
        counter: int = 0
        if i == 0 {
            append(&pruned, tmp)

        } else if !if_found(pruned[:], tmp) {
            append(&pruned, tmp)
        }
    }
    return pruned[:]
}
if_found :: proc (list: [] Vec2, find_pos: Vec2) -> bool {
    leng := len(list)
    found: bool

    for i in 0..<leng {
        if find_pos == list[i] {
            found = true
        }
    }
    return found
}