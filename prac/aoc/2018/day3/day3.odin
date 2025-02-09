package day3
import "core:os"
import "core:fmt"
import "core:strconv"
import "core:strings"

NUM_OF_RECTS :: 1373
FABRIC_SIZE :: 1000

Vec2 :: [2] int
X :: Vec2 { 1, 0 }
Y :: Vec2 { 0, 1 }
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

    squares: [NUM_OF_RECTS] Rectangle
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
                    tmp := strings.trim_space(str)
                    squares[indx].xy.x = strconv.atoi(tmp)
                case 2:
                    run += 1
                    squares[indx].xy.y = strconv.atoi(str)
                case 3:
                    run += 1
                    tmp := strings.trim_space(str)
                    squares[indx].width = strconv.atoi(tmp)
                case 4:
                    run += 1
                    squares[indx].height = strconv.atoi(str) 

            }
        }
        indx += 1
    }

    the_fabric := make(map[Vec2]int, context.temp_allocator)
    overlap: int
    found: bool
    for i in 0..<NUM_OF_RECTS {  // 109,295 too low. 127,831 too high.

        the_fabric[squares[i].xy] += 1

        origin := squares[i].xy
        width := squares[i].width
        height := squares[i].height
        tmpy := origin+Y
        for _ in 0..<height-1 {
            the_fabric[tmpy] += 1
            tmpy += Y
        }

        tmpx := origin+X
        for _ in 0..<width-1 {
            the_fabric[tmpx] += 1
            tmpy = tmpx+Y
            for _ in 0..<height-1 {
                the_fabric[tmpy] += 1
                tmpy += Y
            }
            tmpx += X
        }
    }
    for x in 0..<FABRIC_SIZE {
        for y in 0..<FABRIC_SIZE {
            inVec := Vec2 { x, y } 
            if the_fabric[inVec] > 1 {
                overlap += 1
            }
        }
    }
    fmt.printfln("Part 1 answer: %i", overlap)
    free_all(context.temp_allocator)
}