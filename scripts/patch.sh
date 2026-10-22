#!/bin/bash
# Shadowrun Returns Apple Silicon Compatibility Patch v0.2.0-beta
# Requires user's original game and extracted official Unity 4.2.2f1 files.
set -euo pipefail

VERSION='v0.2.0-beta'
GAME_ROOT=''
UNITY_ROOT=''
OUTPUT_ROOT=''

usage() {
  cat <<'USAGE'
Shadowrun Returns Apple Silicon Compatibility Patch v0.2.0-beta

Usage:
  bash patch.sh --game "/path/to/Shadowrun Returns" \
    --unity "/path/to/Unity.app" --output "/path/to/output folder"

Parameters:
  --game     Directory containing Shadowrun.app (original Steam installation)
  --unity    Unity 4.2.2f1 Unity.app extracted from official macOS installer,
             or its MacStandalonePlayer/UnityPlayer.app directory
  --output   Existing destination directory for a separate patched copy
  --help     Show these instructions

No game or proprietary Unity files are distributed with this script.
The original game is never changed. No existing patched copy is overwritten.
USAGE
}
fail() { printf '\nERROR: %s\n' "$*" >&2; exit 1; }
log() { printf '\n== %s ==\n' "$*"; }
while (($#)); do
  case "$1" in
    --game|--unity|--output)
      (($# >= 2)) || fail "Missing value after $1"
      case "$1" in
        --game) GAME_ROOT="$2";;
        --unity) UNITY_ROOT="$2";;
        --output) OUTPUT_ROOT="$2";;
      esac
      shift 2;;
    -h|--help) usage; exit 0;;
    *) fail "Unknown argument: $1 (use --help)";;
  esac
done
[[ -n "$GAME_ROOT" && -n "$UNITY_ROOT" && -n "$OUTPUT_ROOT" ]] || { usage; fail 'All three paths are required'; }
[[ "$(uname -s)" == 'Darwin' ]] || fail 'This patcher requires macOS'
for cmd in ditto lipo codesign file mktemp; do command -v "$cmd" >/dev/null || fail "Missing tool: $cmd"; done
[[ -d "$GAME_ROOT" && -d "$UNITY_ROOT" && -d "$OUTPUT_ROOT" ]] || fail 'One or more supplied directories do not exist'
SOURCE_APP="$GAME_ROOT/Shadowrun.app"
[[ -d "$SOURCE_APP" ]] || fail "Cannot find $SOURCE_APP"

if [[ -d "$UNITY_ROOT/Contents/PlaybackEngines/MacStandalonePlayer/UnityPlayer.app/Contents" ]]; then
  UC="$UNITY_ROOT/Contents/PlaybackEngines/MacStandalonePlayer/UnityPlayer.app/Contents"
elif [[ -f "$UNITY_ROOT/Contents/MacOS/UnityPlayer" ]]; then
  UC="$UNITY_ROOT/Contents"
else
  fail 'Could not locate MacStandalonePlayer/UnityPlayer.app in --unity path'
fi
PLAYER="$UC/MacOS/UnityPlayer"
MONO="$UC/Frameworks/MonoEmbedRuntime"
[[ -f "$PLAYER" && -d "$MONO" ]] || fail 'Unity Player or Mono runtime missing'
[[ -f "$SOURCE_APP/Contents/Data/level0" ]] || fail 'Missing Contents/Data/level0 in game'
[[ -f "$SOURCE_APP/Contents/Info.plist" ]] || fail 'Missing game Info.plist'
GAME_VERSION=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleVersion' "$SOURCE_APP/Contents/Info.plist" 2>/dev/null || true)
GAME_BUILD=$(/usr/libexec/PlistBuddy -c 'Print :UnityBuildNumber' "$SOURCE_APP/Contents/Info.plist" 2>/dev/null || true)
[[ "$GAME_VERSION" == '4.2.2f1' && "$GAME_BUILD" == '54f0fc09defb' ]] || fail "Unsupported game build: $GAME_VERSION ($GAME_BUILD); expected 4.2.2f1 (54f0fc09defb)"

has_x86_64() { lipo -archs "$1" 2>/dev/null | tr ' ' '\n' | grep -Fxq x86_64; }
log 'Validating 64-bit Unity runtime'
for BINARY in "$PLAYER" "$MONO/osx/libmono.0.dylib" "$MONO/osx/libMonoPosixHelper.dylib"; do
  [[ -f "$BINARY" ]] || fail "Missing: $BINARY"
  has_x86_64 "$BINARY" || fail "No x86_64 architecture: $BINARY"
done
if ! /usr/bin/strings "$PLAYER" 2>/dev/null | grep -Fqm1 '4.2.2f1'; then
  printf 'WARNING: Unity Player binary does not expose the expected version string.\n' >&2
  printf 'Make sure it came from Unity 4.2.2f1.\n' >&2
fi

TARGET="$OUTPUT_ROOT/Shadowrun-AppleSilicon.app"
[[ ! -e "$TARGET" ]] || fail "Destination exists: $TARGET (will not overwrite)"
TMPDIR_PATCH=$(mktemp -d "$OUTPUT_ROOT/.shadowrun-patch.XXXXXX") || fail 'Cannot create staging directory'
cleanup() { [[ -z "${TMPDIR_PATCH:-}" ]] || rm -rf "$TMPDIR_PATCH"; }
trap cleanup EXIT
APP="$TMPDIR_PATCH/Shadowrun-AppleSilicon.app"
log 'Making isolated copy of original game'
ditto "$SOURCE_APP" "$APP"
log 'Replacing player and Mono runtime'
cp "$PLAYER" "$APP/Contents/MacOS/Shadowrun"
chmod +x "$APP/Contents/MacOS/Shadowrun"
ditto "$MONO" "$APP/Contents/Frameworks/MonoEmbedRuntime"
if [[ -f "$APP/installscript_osx.vdf" ]]; then
  mkdir -p "$APP/Contents/Resources/SteamBackup"
  mv "$APP/installscript_osx.vdf" "$APP/Contents/Resources/SteamBackup/installscript_osx.vdf"
fi
log 'Applying ad-hoc signature and validating'
codesign --force --deep --sign - "$APP"
codesign --verify --deep --verbose=2 "$APP"
has_x86_64 "$APP/Contents/MacOS/Shadowrun" || fail 'Resulting app lacks x86_64'
[[ ! -e "$TARGET" ]] || fail "Destination appeared during patching: $TARGET"
mv "$APP" "$TARGET"
rmdir "$TMPDIR_PATCH"
TMPDIR_PATCH=''
trap - EXIT
printf '\nSUCCESS: %s\n' "$TARGET"
printf 'Original game untouched. Tested mode: offline; Steam Cloud and achievements not working.\n'
printf 'Open the new app from Finder. To collect a Unity log:\n'
printf 'arch -x86_64 "%s/Contents/MacOS/Shadowrun" -logFile -\n' "$TARGET"
