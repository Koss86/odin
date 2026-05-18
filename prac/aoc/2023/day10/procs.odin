package day10_2023

import f "core:fmt"
import "core:math"
import "core:os"

Vec2 :: [2]int

UP :: Vec2{0, -1}
DOWN :: Vec2{0, 1}
LEFT :: Vec2{-1, 0}
RIGHT :: Vec2{1, 0}

Direction :: enum {
    Up_Down,
    Left_Right,
    Left_Up,
    Left_Down,
    Right_Up,
    Right_Down,
}

Start :: struct {
    pos:  Vec2,
    dir:  Vec2,
    type: u8,
}

gather_start_data :: proc(pipes: ^[]string) -> (s: Start) {

    s.pos = start_pos(pipes)
    s.type = start_pipe_type(s.pos, pipes)
    s.dir = starting_direction(s.type)

    return s
}

start_pos :: proc(pipes: ^[]string) -> (pos: Vec2) {
    outer: for row, y in pipes {
        for pipe, x in row {
            if pipe == 'S' {
                pos = {x, y}
                break outer
            }
        }
    }
    return pos
}

// Test neighboring pipes in a given direction to see if they point to `s`.
// Then we can infer the pipe type of `s`.
start_pipe_type :: proc(pos: Vec2, pipes: ^[]string) -> (s_pipe: u8) {

    // corrodinates for neighboring pipes
    s_pos: [4]Vec2 = {pos + UP, pos + DOWN, pos + LEFT, pos + RIGHT}

    up_pipe := pipes[s_pos[0].y][s_pos[0].x]
    down_pipe := pipes[s_pos[1].y][s_pos[1].x]
    left_pipe := pipes[s_pos[2].y][s_pos[2].x]
    right_pipe := pipes[s_pos[3].y][s_pos[3].x]

    if check_neighbors({up_pipe, down_pipe}, .Up_Down) {
        s_pipe = '|'

    } else if check_neighbors({left_pipe, right_pipe}, .Left_Right) {
        s_pipe = '-'

    } else if check_neighbors({left_pipe, up_pipe}, .Left_Up) {
        s_pipe = 'J'

    } else if check_neighbors({left_pipe, down_pipe}, .Left_Down) {
        s_pipe = '7'

    } else if check_neighbors({right_pipe, up_pipe}, .Right_Up) {
        s_pipe = 'L'

    } else if check_neighbors({right_pipe, down_pipe}, .Right_Down) {
        s_pipe = 'F'
    }

    return s_pipe
}

// Test the neiborghing pipes if their type matches with the given direction.
check_neighbors :: proc(pipes: [2]u8, check_dir: Direction) -> bool {

    switch check_dir {
        case .Up_Down:
            if pipes.x == '|' || pipes.x == '7' || pipes.x == 'F' {
                if pipes.y == '|' || pipes.y == 'J' || pipes.y == 'L' {
                    return true
                }
            }
        case .Left_Right:
            if pipes.x == '-' || pipes.x == 'L' || pipes.x == 'F' {
                if pipes.y == '-' || pipes.y == '7' || pipes.y == 'J' {
                    return true
                }
            }
        case .Left_Up:
            if pipes.x == '-' || pipes.x == 'L' {
                if pipes.y == '|' || pipes.y == '7' || pipes.y == 'F' {
                    return true
                }
            }
        case .Left_Down:
            if pipes.x == '-' || pipes.x == 'F' {
                if pipes.y == '|' || pipes.y == 'L' || pipes.y == 'J' {
                    return true
                }
            }
        case .Right_Up:
            if pipes.x == '-' || pipes.x == 'J' {
                if pipes.y == '|' || pipes.y == '7' || pipes.y == 'F' {
                    return true
                }
            }
        case .Right_Down:
            if pipes.x == '-' || pipes.x == 'F' {
                if pipes.y == '|' || pipes.y == 'L' || pipes.y == 'J' {
                    return true
                }
            }
    }
    return false
}

starting_direction :: proc(type: u8) -> (dir: Vec2) {
    switch type {
        case '|':
            dir = DOWN
        case '-':
            dir = RIGHT
        case 'J':
            dir = LEFT
        case 'L':
            dir = RIGHT
        case 'F':
            dir = RIGHT
        case '7':
            dir = DOWN
    }
    return dir
}

maze_length :: proc(S: Start, pipes: ^[]string) -> (leng := 1) {

    direction := S.dir
    pos := S.pos + direction

    for pos != S.pos {
        pipe := pipes[pos.y][pos.x]
        pos, direction = move_pos(pos, direction, pipe)
        leng += 1
    }

    return leng
}

move_pos :: proc(position, direction: Vec2, pipe: u8) -> (pos: Vec2, dir: Vec2) {

    pos = position
    dir = direction

    switch pipe {

        case '|':
            if dir == UP {
                pos += UP
            } else if dir == DOWN {
                pos += DOWN
            }

        case '-':
            if dir == LEFT {
                pos += LEFT
            } else if dir == RIGHT {
                pos += RIGHT
            }

        case 'L':
            if dir == DOWN {
                pos += RIGHT
                dir = RIGHT
            } else if dir == LEFT {
                pos += UP
                dir = UP
            }

        case 'F':
            if dir == UP {
                pos += RIGHT
                dir = RIGHT
            } else if dir == LEFT {
                pos += DOWN
                dir = DOWN
            }

        case 'J':
            if dir == DOWN {
                pos += LEFT
                dir = LEFT
            } else if dir == RIGHT {
                pos += UP
                dir = UP
            }

        case '7':
            if dir == UP {
                pos += LEFT
                dir = LEFT
            } else if dir == RIGHT {
                pos += DOWN
                dir = DOWN
            }
    }

    return pos, dir
}

// Make a list of all the corrordinates of the pipes in the maze.
maze_list :: proc(s: Start, pipes: ^[]string) -> []Vec2 {

    direction := s.dir
    pos := s.pos + direction
    dyn_list: [dynamic]Vec2
    append(&dyn_list, s.pos)

    for pos != s.pos {
        append(&dyn_list, pos)
        pipe := pipes[pos.y][pos.x]
        pos, direction = move_pos(pos, direction, pipe)
    }

    return dyn_list[:]
}

// Calculate area using the shoelace formula.
maze_area :: proc(pipes: []Vec2) -> (area: int) {

    l := len(pipes)
    for i in 0 ..< l {
        pos1 := pipes[i]
        pos2 := pipes[(i + 1) % l]
        area += pos1.x * pos2.y - pos2.x * pos1.y
    }

    return math.abs(area) / 2
}

check_ok :: proc(ok: bool, loc := #caller_location) {
    if !ok do panic("Something's not ok", loc)
}

check_err :: proc(err: os.Error, loc := #caller_location) {
    if err != nil {
        f.printfln("Error: %v - %v", err, loc)
        os.exit(1)
    }
}
