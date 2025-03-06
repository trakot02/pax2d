package pax2d

import "core:log"
import "core:time"

//
// Values
//

APP_LAYER_DEFAULT :: App_Layer {
    proc_load   = proc(self: rawptr, app: ^App_State) -> bool { return false },
    proc_unload = proc(self: rawptr, app: ^App_State) {},
    proc_enter  = proc(self: rawptr, app: ^App_State) {},
    proc_leave  = proc(self: rawptr, app: ^App_State) {},
    proc_tick   = proc(self: rawptr, app: ^App_State, delta_time: f32) {},
    proc_update = proc(self: rawptr, app: ^App_State, frame_time: f32) {},
}

//
// Types
//

App_Layer :: struct
{
    self: rawptr,

    proc_load:   proc(self: rawptr, app: ^App_State) -> bool,
    proc_unload: proc(self: rawptr, app: ^App_State),
    proc_enter:  proc(self: rawptr, app: ^App_State),
    proc_leave:  proc(self: rawptr, app: ^App_State),
    proc_tick:   proc(self: rawptr, app: ^App_State, delta_time: f32),
    proc_update: proc(self: rawptr, app: ^App_State, frame_time: f32),
}

App_Layer_Stack :: struct
{
    items: [dynamic]App_Layer,
}

App_Layer_Stack_Iter :: struct
{
    stack: ^App_Layer_Stack,
    index: int,
}

App_State :: struct
{
    // windows
    // input

    graphics: Graphics_State,

    active: bool,
}

App_Conf :: struct
{
    frames_per_second: int,
    frames_max_skip:   int,
}

App :: struct
{
    state: App_State,
    stack: App_Layer_Stack,
}

//
// Procs
//

app_make :: proc(allocator := context.allocator) -> (App, bool)
{
    value := App {}

    value.stack = app_layer_stack_make(allocator)

    value.state.graphics = graphics_start()

    return value, true
}

app_destroy :: proc(self: ^App)
{
    graphics_stop(&self.state.graphics)

    app_layer_stack_destroy(&self.stack)
}

app_push_layer :: proc(self: ^App, value: App_Layer) -> bool
{
    value := app_layer_stack_insert(&self.stack, value)

    return value != 0

    // TODO(gio): Make the layer "enter"
}

app_set_layer :: proc(self: ^App, value: App_Layer) -> bool
{
    app_layer_stack_clear(&self.stack)

    // TODO(gio): Make the layers "leave"

    value := app_layer_stack_insert(&self.stack, value)

    // TODO(gio): Make the layer "enter"

    return value != 0
}

app_pop_layer :: proc(self: ^App)
{
    app_layer_stack_remove(&self.stack)

    // TODO(gio): Make the layer "leave"
}

// TODO(gio): Make app_start

// TODO(gio): Make app_stop

app_tick :: proc(self: ^App, delta_time: f32)
{
    iter := app_layer_stack_bottom(&self.stack)

    for layer in app_layer_stack_next_above(&iter) {
        app_layer_tick(layer, &self.state, delta_time)
    }
}

app_update :: proc(self: ^App, frame_time: f32)
{
    iter := app_layer_stack_bottom(&self.stack)

    for layer in app_layer_stack_next_above(&iter) {
        app_layer_update(layer, &self.state, frame_time)
    }
}

app_loop :: proc(self: ^App, layer: App_Layer, conf: App_Conf) -> bool
{
    tick := time.Tick {}

    frame_rate := f64(conf.frames_per_second)
    delta_time := f64(1)
    frame_time := f64 {}
    total_time := f64 {}

    if frame_rate < delta_time {
        frame_rate = delta_time
    }

    delta_time /= frame_rate

    self.state.active = app_set_layer(self, layer)

    if self.state.active == false {
        return false
    }

    for skips := 0; app_layer_stack_len(&self.stack) != 0; skips = 0 {
        duration   := time.tick_lap_time(&tick)
        frame_time  = time.duration_seconds(duration)

        log.debugf("frame_time in seconds = %v", frame_time)

        total_time += frame_time

        // TODO(gio): render clear

        for delta_time < total_time && skips <= conf.frames_max_skip {
            app_tick(self, f32(delta_time))

            total_time -= delta_time
            skips      += 1
        }

        app_update(self, f32(frame_time))

        // TODO(gio): render flush, swap buffers

        if self.state.active == false { break }
    }

    return true
}

app_layer_default :: proc() -> App_Layer
{
    return APP_LAYER_DEFAULT
}

app_layer_load :: proc(self: ^App_Layer, app: ^App_State) -> bool
{
    return self.proc_load(self.self, app)
}

app_layer_unload :: proc(self: ^App_Layer, app: ^App_State)
{
    self.proc_unload(self.self, app)
}

app_layer_enter :: proc(self: ^App_Layer, app: ^App_State)
{
    self.proc_enter(self.self, app)
}

app_layer_leave :: proc(self: ^App_Layer, app: ^App_State)
{
    self.proc_leave(self.self, app)
}

app_layer_tick :: proc(self: ^App_Layer, app: ^App_State, delta_time: f32)
{
    self.proc_tick(self.self, app, delta_time)
}

app_layer_update :: proc(self: ^App_Layer, app: ^App_State, frame_time: f32)
{
    self.proc_update(self.self, app, frame_time)
}

app_layer_stack_make :: proc(allocator := context.allocator) -> App_Layer_Stack
{
    return App_Layer_Stack {
        items = make([dynamic]App_Layer, allocator)
    }
}

app_layer_stack_destroy :: proc(self: ^App_Layer_Stack)
{
    delete(self.items)

    self.items = {}
}

app_layer_stack_len :: proc(self: ^App_Layer_Stack) -> int
{
    return len(self.items)
}

app_layer_stack_clear :: proc(self: ^App_Layer_Stack)
{
    clear(&self.items)
}

app_layer_stack_insert :: proc(self: ^App_Layer_Stack, value: App_Layer) -> int
{
    _, error := append(&self.items, value)

    if error != nil {
        log.errorf("App_Layer_Stack: Unable to insert layer")

	return 0
    }

    return len(self.items)
}

app_layer_stack_remove :: proc(self: ^App_Layer_Stack) -> (App_Layer, bool)
{
    count := len(self.items)

    if count > 0 {
        index := count - 1
        value := self.items[index]

        resize(&self.items, index)

        return value, true
    }

    return {}, false
}

app_layer_stack_bottom :: proc(self: ^App_Layer_Stack) -> App_Layer_Stack_Iter
{
    return App_Layer_Stack_Iter {
        stack = self,
    }
}

app_layer_stack_next_above :: proc(self: ^App_Layer_Stack_Iter) -> (^App_Layer, int, bool)
{
    count := len(self.stack.items)
    index := self.index

    if index >= 0 && index < count {
        value := &self.stack.items[index]
        next  := index + 1

        self.index = next

        return value, next, true
    }

    return nil, 0, false
}
