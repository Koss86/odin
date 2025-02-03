package day3

import "core:fmt"
import "core:os"
import strs "core:strings"
Vec2i :: [2] int
UP :: Vec2i {0,1}
DOWN :: Vec2i {0,-1}
LEFT :: Vec2i {-1,0}
RIGHT :: Vec2i {1,0}


main :: proc() {

    file := "../inputs/input3.txt"
    buff, ok := os.read_entire_file(file, context.allocator)
    if !ok {
        fmt.eprintln("Unable to read file")
        return
    }
    defer delete(buff, context.allocator)
    
    santa_visits := make([dynamic] Vec2i)  // size will be 8192
    santa_pos: Vec2i
    move: Vec2i
    leng := len(buff)
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
    fmt.println(leng)
    /*
    leng = len(santa_visits)
    repeats : [leng] [leng] bool

    for x in 0..<leng {
        for y in 0..<leng {
            
        }
    }
        */
}

prune_list :: proc(list: [] Vec2i) -> [] Vec2i {

    pruned := make([dynamic] Vec2i, context.allocator)
    leng := len(list)
    duplicate: int

    for i in 0..<leng {
        tmp := list[i]
        counter: int = 0
        for j in 0..<leng {
            if i == 0 {
                append(&pruned, tmp)
            } else if !if_found(pruned[:], tmp) {
                append(&pruned, tmp)
            }
            
        }
    }
    return pruned[:]
}
if_found :: proc (c_list: [] Vec2i, find_pos: Vec2i) -> bool {
    leng := len(c_list)
    found: bool
    for i in 0..<leng {
        if find_pos == c_list[i] {
            found = true
        }
    }
    return found
}