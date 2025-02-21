package day6
import "core:os"
import "core:fmt"
import "core:mem"
import "core:strconv"
import "core:strings"

DB_SIZE :: 300
GRID :: 1000
ON :: true
OFF:: false
Vec2 :: [2]int
Action :: enum {
    turn_on,
    turn_off,
    toggle,
}
Instructions :: struct {
    act: Action,
    vec1: Vec2,
    vec2: Vec2,
    brightness: int,
}

main :: proc() {
    default_allocator := context.allocator
    tracking_allocator: mem.Tracking_Allocator
    mem.tracking_allocator_init(&tracking_allocator, default_allocator)
    context.allocator = mem.tracking_allocator(&tracking_allocator)

    file: string
    test := false
    if test {
        file = "test.txt"
    } else {
        file = "../inputs/input6.txt"
    }
    buff, ok := os.read_entire_file(file, context.allocator)
    if !ok {
        panic("ERROR. Unable to open file.")
    }
    indx: int
    input := string(buff)
    santas_inscructs := make([]Instructions, DB_SIZE, context.allocator)
    for line in strings.split_lines_iterator(&input) {
        tmp_str := line
        splits := []string { "-", "," }
        ct: int
        for str in strings.split_multi_iterate(&tmp_str, splits) {
            switch ct {
                case 0:
                    if str == "turn on"{
                        santas_inscructs[indx].act = .turn_on
                    } else if str == "turn off" {
                        santas_inscructs[indx].act = .turn_off
                    } else {
                        santas_inscructs[indx].act = .toggle
                    }
                case 1:
                    santas_inscructs[indx].vec1.x = strconv.atoi(str)
                case 2:
                    santas_inscructs[indx].vec1.y = strconv.atoi(str)
                case 3:
                    santas_inscructs[indx].vec2.x = strconv.atoi(str)
                case 4:
                    santas_inscructs[indx].vec2.y = strconv.atoi(str)
            }
            ct += 1
        }
        indx += 1
    }
    lights := make(map[Vec2]bool, context.allocator)
    brightness := make(map[Vec2]int, context.allocator) // todo: combine maps with custom struct :: {brght: int, state: bool}
    for i in 0..<DB_SIZE {
        vec1 := santas_inscructs[i].vec1
        vec2 := santas_inscructs[i].vec2
        switch santas_inscructs[i].act {
            case .turn_on:
                for x in vec1.x..=vec2.x {
                    for y in vec1.y..=vec2.y {
                        lights[{x,y}] = ON
                        brightness[{x,y}] += 1
                    }
                }
            case .turn_off:
                for x in vec1.x..=vec2.x {
                    for y in vec1.y..=vec2.y {
                        lights[{x,y}] = OFF
                        brightness[{x,y}] -= 1
                        if brightness[{x,y}] < 0 {
                            brightness[{x,y}] = 0
                        }
                    }
                }
            case .toggle:
                for x in vec1.x..=vec2.x {
                    for y in vec1.y..=vec2.y {
                        if lights[{x,y}] == ON {
                            lights[{x,y}] = OFF
                        } else {
                            lights[{x,y}] = ON
                        }
                        //lights[{x,y}] = !lights[{x,y}]
                        brightness[{x,y}] += 2
                    }
                }
        }
    }
    lights_on: int
    brght_lvl: int
    for x in 0..<GRID {
        for y in 0..<GRID {
            if lights[{x,y}] {
                lights_on += 1
            }
            brght_lvl += brightness[{x,y}]
        }
    }
    fmt.printfln("Part 1 answer: %v", lights_on)
    fmt.printfln("Part 2 answer: %v", brght_lvl)
}