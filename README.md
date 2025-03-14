# sqlite-vec wrapper for .NET

This is a .NET wrapper for the [sqlite-vec](https://github.com/asg017/sqlite-vec.git). It is a simple wrapper that allows you to use the sqlite-vec library in your .NET projects.

## Build

### Prerequisites

- [.NET Core SDK](https://dotnet.microsoft.com/download)
- [CMake](https://cmake.org/download/)
- (Optional) [Ninja Build](https://github.com/ninja-build/ninja)

Supported compilers:

- Visual Studio 2019 or later
- GCC 8 or later
- Clang 7 or later

For non-Windows platforms, you will need to install the [Mono](https://www.mono-project.com/download/stable/) runtime. You can install it using your package manager, or its official system installer.

### Building

1. Clone the repository
2. Build with `CMake`

    ```bash
    mkdir build
    cd build
    cmake ..
    cmake --build .
    ```

### Usage

The library is built as a NuGet package, and you can use it in your .NET projects by adding a package reference.
