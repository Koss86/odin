package hangman
import "core:os"
import "core:fmt"
import "core:math"
import "core:time"
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
    seed:= rl.GetTime()
    //rl.SetRandomSeed(seed)
    rand := rl.GetRandomValue(1, 20)
    fmt.println(seed)
    fmt.println(rand)
    expected_leng: int
    if os_platform == .Linux {
        expected_leng = 2
    } else if os_platform == .Windows {
        expected_leng = 3
    }
    scores: [10]int
    fmt.print("Guess a letter: ")
    num_of_stdin, _ = os.read(os.stdin, buff[:])
    for num_of_stdin != expected_leng || buff[0] == 32 {
        fmt.printf("Please guess one letter only and no spaces.\nGuess a letter: ")
        num_of_stdin, _ = os.read(os.stdin, buff[:])
    }
    fmt.println(num_of_stdin)
    fmt.println(buff[0])
    

    tmp_str = string(buff[:])
    
    if os_platform == .Linux {
        indx = bytes.index_byte(buff[:], 10)
    } else if os_platform == .Windows {
        indx = bytes.index_byte(buff[:], 13)
    }
    
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