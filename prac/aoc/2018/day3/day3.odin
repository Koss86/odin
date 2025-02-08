package day3
import "core:os"
import "core:fmt"
import "core:strconv"
import "core:strings"
X :: Vec2 { 1, 0 }
Y :: Vec2 { 0, 1 }

NUM_OF_RECTS :: 1373

Vec2 :: [2] int
Rectangle :: struct {
    xy: Vec2,
    width: int, height: int
}

main :: proc() {
    buff, ok := os.read_entire_file("../inputs/input3.txt", context.temp_allocator)
    if !ok {
        fmt.eprintln("Error. Unable to read file.")
        return
    }

    elves_suggestions: [NUM_OF_RECTS] Rectangle
    it := string(buff)
    indx: int
    for line in strings.split_lines_iterator(&it) {
        run: int
        tmp_str := line
        splits := []string {"@", ",", ":", "x"}
        for str in strings.split_multi_iterate(&tmp_str, splits[:]) {
            switch run {
                case 0:
                    run += 1
                case 1:
                    run += 1
                    tmp := str
                    tmp = strings.trim_space(str)
                    elves_suggestions[indx].xy.x = strconv.atoi(tmp)
                case 2:
                    run += 1
                    elves_suggestions[indx].xy.y = strconv.atoi(str)
                case 3:
                    run += 1
                    tmp := str
                    tmp = strings.trim_space(str)
                    elves_suggestions[indx].width = strconv.atoi(tmp)
                case 4:
                    run += 1
                    elves_suggestions[indx].height = strconv.atoi(str) 

            }
        }
        indx += 1
    }

    the_fabric := make(map[Vec2]int, context.temp_allocator)

    for i in 0..<NUM_OF_RECTS {

        the_fabric[elves_suggestions[i].xy] += 1

        corner := elves_suggestions[i].xy
        cornerX := elves_suggestions[i].width
        cornerY := elves_suggestions[i].height

        if cornerX > cornerY {
            tmpx := corner+X
            for _ in 0..<cornerX {
                the_fabric[tmpx] += 1
                tmpy := corner+X+Y
                for _ in 0..<cornerY {
                    the_fabric[tmpy] += 1
                    tmpy += Y
                }
                tmpx += X
            }
        } else {
            tmpy := corner+Y
            for _ in 0..<cornerY {
                the_fabric[tmpy] += 1
                tmpx := corner+X+Y
                for _ in 0..<cornerX {
                    the_fabric[tmpx] += 1
                    tmpx += X
                }
                tmpy += Y
            }
        }
    }
    overlap: int
    found: bool
    for i in 0..<NUM_OF_RECTS {
        corner := elves_suggestions[i].xy
        cornerX := elves_suggestions[i].width
        cornerY := elves_suggestions[i].height
        for _ in 0..<cornerX {
            
        }

    }
    fmt.printfln("Part 1 answer: %i", overlap/NUM_OF_RECTS)
    free_all(context.temp_allocator)
}