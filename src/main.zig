const std = @import("std");
const glfw = @import("mach-glfw");
const gl = @import("gl");

const GameWindowError = error {
    CouldNotInitGlfw,
    CouldNotCreateWindow
};

const GameWindow = struct {
    window: glfw.Window,
    const Self = @This();

    pub fn init() !GameWindow {
        glfw.setErrorCallback(errorCallback);
        if (!glfw.init(.{})) {
            return GameWindowError.CouldNotInitGlfw;
        }

        const window = try createWindow();
        try initGl();
        window.setSizeCallback(resizeCallback);

        return .{
            .window = window,
        };
    }
    
    // Default GLFW error handling callback
    fn errorCallback(error_code: glfw.ErrorCode, description: [:0]const u8) void {
        std.log.err("glfw: {}: {s}\n", .{ error_code, description });
    }

    pub fn resizeCallback(_: glfw.Window, width: i32, height: i32) void {
        gl.viewport(0, 0, width, height);
    }

    pub fn createWindow() !glfw.Window {
        const window = glfw.Window.create(1920, 1080, "Hello, mach-glfw!", null, null, .{
            .opengl_profile = .opengl_core_profile,
            .context_version_major = 3,
            .context_version_minor = 0,
            .client_api = .opengl_es_api,
        }) orelse {
            return GameWindowError.CouldNotCreateWindow;
        };
        glfw.makeContextCurrent(window);
        return window;
    }

    fn initGl() !void {
        const proc: glfw.GLProc = undefined;
        try gl.load(proc, glGetProcAddress);
        gl.viewport(0, 0, 1920, 1080);
    }

    fn glGetProcAddress(p: glfw.GLProc, proc: [:0]const u8) ?gl.FunctionPointer {
        _ = p;
        return glfw.getProcAddress(proc);
    }

    pub fn clearWindow(_: Self) void {
        gl.clearColor(1, 0, 1, 1);
        gl.clear(gl.COLOR_BUFFER_BIT);
    }

    pub fn swapBuffers(self: Self) void {
        self.window.swapBuffers();
    } 

    pub fn handleInput(self: Self) void {
        glfw.pollEvents();

        if (self.window.getKey(.escape) == .press) {
            self.window.setShouldClose(true);
        }
    }

    pub fn deinit(self: Self) void {
        self.window.destroy();
        glfw.terminate();
    }

    pub fn shouldClose(self: Self) bool {
        return self.window.shouldClose();
    }
};



pub fn main() !void {
    const gameWindow = try GameWindow.init();
    defer gameWindow.deinit();


    // Wait for the user to close the window.
    while (!gameWindow.shouldClose()) {
        gameWindow.handleInput();

        gameWindow.clearWindow();
        gameWindow.swapBuffers();
    }
}
