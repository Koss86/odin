package hangman
import "core:os"
import "core:fmt"
import "core:math"
import "core:bytes"
import "core:strconv"
import "core:strings"
import "core:sys/info"
import rl "vendor:raylib"



main :: proc() {
    //list := []string {"coffee", "castaway", "broken", "laptop", "driven"}
    buff: [16]byte
    w, h: int
    indx: int
    tmp_str: string
    tmp_num_str: string
    num_of_stdin: int
    os_platform := info.os_version.platform
/*
    fmt.print("Width? ")
    num_of_stdin, _ = os.read(os.stdin, buff[:])
    if os_platform == .Linux {
        indx = bytes.index_byte(buff[:], 10)
    } else {
        indx = bytes.index_byte(buff[:], 13)
    }

    tmp_str = string(buff[:])
    w = strconv.atoi(tmp_str[:indx])

    fmt.print("Height? ")
    num_of_stdin, _ = os.read(os.stdin, buff[:])

    if os_platform == .Linux {
        indx = bytes.index_byte(buff[:], 10)
    } else {
        indx = bytes.index_byte(buff[:], 13)
    }
    h = strconv.atoi(tmp_str[:indx])
    
    for i in 0..<h {
        for j in 0..<w {
            fmt.printf("#")
        }
        fmt.println()
    }
*/
    scores: [10]int
    fmt.print("Enter scores to average: ")
    num_of_stdin, _ = os.read(os.stdin, buff[:])
    

    tmp_str = string(buff[:])
    
    if os_platform == .Linux {
        indx = bytes.index_byte(buff[:], 10)
    } else {
        indx = bytes.index_byte(buff[:], 13)
    }
    tmp_num_str = tmp_str[:indx]
    indx = 0
    for str in strings.split_iterator(&tmp_num_str, " ") {
        scores[indx] = strconv.atoi(str)
        indx += 1
    }
    avg := avg_scores(scores[:])
    fmt.println(avg)
}

avg_scores :: proc(scores: []int) -> f32 {
    sum: f32
    ct: f32
    for v in scores {
        if v > 0 {
            sum += f32(v)
            ct += 1
        }
    }
    return sum/ct
}
/*
OS:    OS_Version{
        platform = "Linux",
        _ = Version{
                major = 6,
                minor = 8,
                patch = 0,
        },
        build = [
                0,
                0,
        ],
        version = "53-generic",
        as_string = "Linux Mint 22.1, Linux 6.8.0-53-generic",
}
*/