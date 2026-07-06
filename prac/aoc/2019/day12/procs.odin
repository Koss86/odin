package day12_2019

import f "core:fmt"
import "core:math"
import "core:os"
import sc "core:strconv"
import s "core:strings"

AXIS :: 3

Vec3 :: [3]int

Pos_Vel :: struct {
    pos: Vec3,
    vel: Vec3,
}

parse_file :: proc(file: []u8) -> []Pos_Vel {

    str_file := string(file)
    moons: [dynamic]Pos_Vel

    for line in s.split_lines_iterator(&str_file) {
        line := line
        vec_buf: [dynamic]int
        for str in s.split_iterator(&line, ",") {
            i := s.index(str, "=")
            trim := s.trim_right(str, ">")
            n, ok := sc.parse_int(trim[i + 1:])
            check_ok(ok)
            append(&vec_buf, n)
        }
        moon: Pos_Vel
        for n, i in vec_buf {
            moon.pos[i] = n
        }
        delete(vec_buf)
        append(&moons, moon)
    }

    return moons[:]
}

simulate_orbits :: proc(moons: []Pos_Vel, time: int) {
    for _ in 0 ..< time {
        for i in 0 ..< len(moons) - 1 {
            for j in i + 1 ..< len(moons) {
                update_velocity(&moons[i], &moons[j])
            }
        }
        update_position(moons)
    }
}

update_velocity :: proc(m1, m2: ^Pos_Vel) {
    for i in 0 ..< len(m1.pos) {
        if m1.pos[i] > m2.pos[i] {
            m1.vel[i] -= 1
            m2.vel[i] += 1
        } else if m1.pos[i] < m2.pos[i] {
            m1.vel[i] += 1
            m2.vel[i] -= 1
        }
    }
}

update_position :: proc(m: []Pos_Vel) {
    for i in 0 ..< len(m) {
        m[i].pos += m[i].vel
    }
}

calculate_energy :: proc(m: []Pos_Vel) -> int {
    potential, kenetic, total: int
    for i in 0 ..< len(m) {
        potential = math.abs(m[i].pos.x)
        potential += math.abs(m[i].pos.y)
        potential += math.abs(m[i].pos.z)
        kenetic = math.abs(m[i].vel.x)
        kenetic += math.abs(m[i].vel.y)
        kenetic += math.abs(m[i].vel.z)
        total += potential * kenetic
    }
    return total
}

loop_length :: proc(init: []Pos_Vel) -> int {

    loops: Vec3
    cpy := copy_list(init)
    defer delete(cpy)

    for axis in 0 ..< AXIS {
        count: int
        for {
            for i in 0 ..< len(cpy) - 1 {
                for j in i + 1 ..< len(cpy) {
                    update_axis_velocity(&cpy[i], &cpy[j], axis)
                }
            }
            count += 1
            update_axis_position(cpy, axis)
            if check_axis_state(cpy, init, axis) {
                loops[axis] = count
                break
            }
        }
    }
    return math.lcm(math.lcm(loops[0], loops[1]), loops[2])
}

update_axis_velocity :: proc(m1, m2: ^Pos_Vel, axis: int) {
    if m1.pos[axis] > m2.pos[axis] {
        m1.vel[axis] -= 1
        m2.vel[axis] += 1
    } else if m1.pos[axis] < m2.pos[axis] {
        m1.vel[axis] += 1
        m2.vel[axis] -= 1
    }
}

update_axis_position :: proc(m: []Pos_Vel, axis: int) {
    for i in 0 ..< len(m) {
        m[i].pos[axis] += m[i].vel[axis]
    }
}

check_axis_state :: proc(cpy, init: []Pos_Vel, axis: int) -> bool {
    for i in 0 ..< len(cpy) {
        pos1, pos2 := cpy[i].pos[axis], init[i].pos[axis]
        vel1, vel2 := cpy[i].vel[axis], init[i].vel[axis]
        if pos1 != pos2 || vel1 != vel2 do return false
    }
    return true
}

copy_list :: proc(l: []$E) -> []E {
    c: [dynamic]E
    for v in l { append(&c, v) }
    return c[:]
}

run_examples :: proc() {

    file, err := os.read_entire_file("example1", context.allocator)
    check_err(err)

    moons := parse_file(file)
    simulate_orbits(moons, 10)
    f.println("Example 1:", calculate_energy(moons))
    delete(moons)

    moons = parse_file(file)
    f.println("Example 2:", loop_length(moons))
    delete(moons)
    delete(file)

    file, err = os.read_entire_file("example2", context.allocator)
    check_err(err)
    moons = parse_file(file)
    f.println("Example 3:", loop_length(moons), "\n")
    delete(moons)
    delete(file)
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
