# Changelog

## v0.2.0-beta — 2026-10-22

- Initial public beta of the stand-alone macOS compatibility patcher.
- Replaces 32-bit Unity 4.2.2f1 Player with matching 64-bit Intel player.
- Copies matching Mono runtime and ad-hoc signs the resulting app.
- Creates an isolated patched copy; never overwrites the original installation.
- Supports configurable source game, extracted Unity and output paths.
- Verified on Apple M4 running macOS 26.5.2: launch, campaign start, saving and loading across restarts.
- Known limitation: Steam integration/Cloud/achievements unavailable or unverified.

No copyrighted game or Unity engine binaries are distributed.
