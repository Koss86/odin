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
    num_bytes: int
    os_platform := info.os_version.platform

    fmt.print("Width? ")
    num_bytes, _ = os.read(os.stdin, buff[:])
    if os_platform == .Linux {
        indx = bytes.index_byte(buff[:], 10)
    } else {
        indx = bytes.index_byte(buff[:], 13)
    }
    tmp_str := string(buff[:])
    w = strconv.atoi(tmp_str[:indx])
    fmt.print("Height? ")
    num_bytes, _ = os.read(os.stdin, buff[:])

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
    fmt.print("Enter scores to average: ")
    num_bytes, _ = os.read(os.stdin, buff[:])
    fmt.println(tmp_str)

}

avg_scores :: proc(scores: []int) -> int {
    leng := len(scores)
    sum: int
    for i in 0..<leng {
        sum += scores[i]
    }
    return sum/leng
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