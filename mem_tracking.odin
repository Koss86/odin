package mem_tracking
import "core:fmt"
import "core:mem"

mem_tracking :: proc() {
    when ODIN_DEBUG {
        track1: mem.Tracking_Allocator
        track2: mem.Tracking_Allocator
        mem.tracking_allocator_init(&track1, context.allocator)
        mem.tracking_allocator_init(&track2, context.temp_allocator)
        context.allocator = mem.tracking_allocator(&track1)
        context.temp_allocator = mem.tracking_allocator(&track2)
        defer {
            if len(track1.allocation_map) > 0 {
                for _, entry in track1.allocation_map {
                    fmt.eprintf("%v leaked %v bytes\n", entry.location, entry.size)
                }
            }
            if len(track2.allocation_map) > 0 {
                for _, entry in track2.allocation_map {
                    fmt.eprintf("%v leaked %v bytes\n", entry.location, entry.size)
                }
            }
            mem.tracking_allocator_destroy(&track1)
            mem.tracking_allocator_destroy(&track2)
        }
    }
}
