# Local Codex Environment — Windows

## Status

Validated on 2026-07-21.

The Codex desktop app can access the local clone, execute shell commands, read repository instructions, fetch from the fork, initialize the supported Windows compiler environment, configure the project, and complete a clean Debug build.

## Repository

- Local project root: `C:\GitHub\server`
- Repository: `djjohnson13p/server`
- Required branch: `retail-parity/codex-vanilla-zilart`
- Validation commit: `2ecefb7fadc15d7a849ff25809d9ad0fad165552`
- `origin`: `https://github.com/djjohnson13p/server.git`
- `upstream` fetch: `https://github.com/LandSandBoat/server.git`
- `upstream` push: disabled through an invalid push URL
- Recursive fetch/submodule behavior: disabled for normal Git fetches

Both recorded top-level submodules were present at their pinned commits during the build:

- `navmeshes`: `d5de48de84868bde744e4864768a611e5aad82b0`
- `ximeshes`: `906d725cb40ed4eeeaa8299bb95922dca31be2d5`

## Validated tools

- Git: `2.54.0.windows.1`
- Python: `3.14.6`
- CMake: `4.3.3`
- Ninja: `1.13.2`
- Visual Studio Build Tools 2022: `17.14.35`
- MSVC tools: `14.44.35207`
- `cl`: `19.44.35228` for x64
- `link`: `14.44.35228.0`
- Windows SDK: `10.0.26100.0`

Clang is not required for the validated Windows path. MinGW GCC was not used as a substitute.

## Developer-environment initialization

Use the Visual Studio developer command environment before configuring or building:

```bat
call "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\Common7\Tools\VsDevCmd.bat" -no_logo -arch=x64 -host_arch=x64
```

An ordinary shell may report that `cl` is unavailable until this command has run. That is expected and does not mean MSVC is missing.

## Validated clean Debug build

Configure:

```bat
call "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\Common7\Tools\VsDevCmd.bat" -no_logo -arch=x64 -host_arch=x64 && cmake -G Ninja -S . -B build-codex-smoke --fresh -DCMAKE_BUILD_TYPE=Debug -DENABLE_CLANG_TIDY=OFF -DTRACY_ENABLE=OFF -DPCH_ENABLE=OFF -DCACHE_OPTION=sccache
```

Result:

- C compiler: MSVC `19.44.35228.0`
- C++ compiler: MSVC `19.44.35228.0`
- Generator: Ninja
- Build type: Debug
- Configuration exit code: `0`

Build:

```bat
call "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\Common7\Tools\VsDevCmd.bat" -no_logo -arch=x64 -host_arch=x64 && cmake --build build-codex-smoke
```

Result:

- All `1049/1049` Ninja steps completed.
- `xi_connect.exe`, `xi_map.exe`, `xi_search.exe`, `xi_world.exe`, and `xi_test.exe` linked successfully.
- Build exit code: `0`.

## Cleanup and repository state

The disposable build directory and generated root executables/PDBs were removed after validation. The final worktree was clean and remained on `retail-parity/codex-vanilla-zilart`.

## Codex operating rules

- Use this MSVC/Ninja path for Windows build validation.
- Initialize `VsDevCmd.bat` inside each new shell command environment that requires MSVC.
- Use disposable out-of-tree build directories unless a task explicitly requires preserving artifacts.
- Remove generated executables, PDBs, and temporary build directories before committing unless the task requires them.
- Never modify `base` directly.
- Never push to or open a pull request against `LandSandBoat/server`.
- Push only to the selected fork branch when the task explicitly permits it.
