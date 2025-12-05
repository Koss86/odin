package day7_2017
import "core:fmt"
import "core:os"
import "core:strconv"
import "core:strings"

prog :: struct {
    name:     string,
    weight:   int,
    children: [dynamic]string,
}

bwMap: map[string]int // branch weight of program (self+subtowers)
cMap: map[string]int // number of children each program has
iMap: map[string]int // index into List for each program
wMap: map[string]int // weight of each program

main :: proc() {
    context.allocator = context.temp_allocator
    file, ok := os.read_entire_file("input")
    checkOk(ok)
    strFile := string(file)
    Lines := strings.split_lines(strFile)
    List: [dynamic]prog

    for line in Lines {
        Strs := strings.split(line, " ")
        childBuf: [dynamic]string
        nodeBuf: prog
        for str, i in Strs {
            switch i {
                case 0:
                    nodeBuf.name = str
                case 1:
                    tmp, _ := strings.remove(str, "(", 1)
                    tmp, _ = strings.remove(tmp, ")", 1)
                    nodeBuf.weight, ok = strconv.parse_int(tmp)
                    checkOk(ok)
                case 2:
                    // Skip the "->"
                    continue
                case:
                    str := str
                    leng := len(str)
                    if str[leng - 1:] == "," {
                        str, _ = strings.remove(str, ",", 1)
                    }
                    append(&childBuf, str)
            }
        }
        nodeBuf.children = childBuf
        append(&List, nodeBuf)
    }

    isChild: map[string]bool
    for prog, i in List {
        if len(prog.children) > 0 {
            for child in prog.children {
                isChild[child] = true
            }
        }
        iMap[prog.name] = i
        wMap[prog.name] = prog.weight
        cMap[prog.name] = len(prog.children)
    }

    rootProg: string
    for prog, i in List {
        if !isChild[prog.name] {
            rootProg = prog.name
            fmt.println("Part 1 answer:", rootProg)
            break
        }
    }

    found: bool
    findImbalance(&List, rootProg, &found)
    free_all(context.temp_allocator)
}
findImbalance :: proc(List: ^[dynamic]prog, parent: string, found: ^bool) -> int {

    if cMap[parent] == 0 {
        bwMap[parent] = wMap[parent]
        return bwMap[parent]
    }

    weight: int
    cWeight: [dynamic]int
    parentIndx := iMap[parent]

    for child in List[parentIndx].children {
        weight = findImbalance(List, child, found)
        append(&cWeight, weight)
    }

    weight = 0
    for childWeight in cWeight {
        weight += childWeight
    }

    bwMap[parent] = wMap[parent] + weight

    // compare children's weight
    w1 := cWeight[0]
    balanced := true
    imbaIndx: int
    for i := 1; i < len(cWeight); i += 1 {
        w2 := cWeight[i]
        if w1 != w2 {
            balanced = false
            imbaIndx = i
            break
        }
    }
    // If unbalanced, the weight will be in either index 0 or i of cWeight,
    // below determins if 0 or i is the correct index for the unbalanced weight.
    // And since the weights were appended in order, the same index will work to
    // index into List[].children to get the name of the unbalanced branch.
    if !balanced && !found^ {
        found^ = true
        balIndx: int
        for i := 1; i < len(cWeight); i += 1 {
            if i == imbaIndx {
                continue
            }
            w2 := cWeight[i]
            if w1 != w2 {
                imbaIndx = 0
                balIndx = 1
            }
        }
        imbaBranch := List[parentIndx].children[imbaIndx]
        balBranch := List[parentIndx].children[balIndx]
        dif := bwMap[balBranch] - bwMap[imbaBranch]
        fmt.println("Part 2 answer:", wMap[imbaBranch] + dif)

        // fmt.printfln(
        //     "%s (%i)[%i] is unbalanced, child of %s (%i)[%i]",
        //     imbaBranch,
        //     wMap[imbaBranch],
        //     bwMap[imbaBranch],
        //     parent,
        //     wMap[parent],
        //     bwMap[parent],
        // )
        // fmt.printfln("Peer programs of %s:", imbaBranch)
        // for child in List[parentIndx].children {
        //     fmt.println(child, wMap[child], bwMap[child])
        // }
        // fmt.printfln("Programs in subtower %s:", imbaBranch)
        // for child in List[iMap[imbaBranch]].children {
        //     fmt.println(child, wMap[child], bwMap[child])
        // }
    }
    return bwMap[parent]
}
checkOk :: proc(ok: bool, loc := #caller_location) {
    if !ok {
        panic("Somthing's not ok.", loc)
    }
}
