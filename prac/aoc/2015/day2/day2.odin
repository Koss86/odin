package day2

import "core:os"
import "core:fmt"
import "core:sort"
import "core:strconv"
import "core:strings"

SIZE :: 1000

Rectangle :: struct {
    l: int,
    w: int,
    h: int
}

main :: proc() {
    buff, ok := os.read_entire_file("../inputs/input2.txt", context.temp_allocator)
    if !ok {
        fmt.eprintln("Unable to read file.")
        return
    }
    wraping_paper_dimensions := make([]Rectangle, SIZE, context.allocator)
    input := string(buff)
    indx: int
    run: int
    for line in strings.split_lines_iterator(&input) {
        tmp_ln := line
        for str in strings.split_iterator(&tmp_ln, "x") {
            switch run {
                case 0:
                    wraping_paper_dimensions[indx].l = strconv.atoi(str[:])
                    run += 1
                case 1:
                    wraping_paper_dimensions[indx].w = strconv.atoi(str[:])
                    run += 1
                case 2:
                    wraping_paper_dimensions[indx].h = strconv.atoi(str[:])
                    run = 0
            }
        }
        indx += 1
    }
    delete(buff, context.temp_allocator)
    total1: int
    total2: int
    // 2*l*w + 2*w*h + 2*l*h
    for i in 0..<SIZE {
        paper := wraping_paper_dimensions[i]
        dim0 := paper.l * paper.w
        dim1 := paper.w * paper.h
        dim2 := paper.l * paper.h
        extra := dim0
        paper_dim_sorted :[]int=  { paper.l, paper.w, paper.h }
        sort.bubble_sort(paper_dim_sorted[:])

        if extra > dim1 { extra = dim1 }
        if extra > dim2 { extra = dim2 }
        
        tmp := 2*(dim0+dim1+dim2)+extra
        total1 += tmp
        total2 += 2*(paper_dim_sorted[0]+paper_dim_sorted[1])+(paper.l * paper.w * paper.h)
    }
    fmt.printfln("Part 1 answer: %v", total1)
    fmt.printfln("Part 2 answer: %v", total2)

}