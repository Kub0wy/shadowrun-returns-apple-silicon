<div align="center">

# SHADOWRUN RETURNS
## APPLE SILICON COMPATIBILITY PATCH

**Bring the original macOS release back to life on modern Macs.**

A community-built patch for the original macOS edition of *Shadowrun Returns*. Swap the game's obsolete 32-bit Unity Player for its matching **64-bit Intel Unity 4.2.2f1 player** and run it on Apple Silicon using **Rosetta 2** — no Wine, CrossOver or Windows required.

[![macOS](https://img.shields.io/badge/platform-macOS-181717?style=for-the-badge&logo=apple&logoColor=white)](#compatibility)
[![Apple Silicon](https://img.shields.io/badge/Apple_Silicon-Rosetta_2-343a40?style=for-the-badge)](#how-it-works)
[![Beta](https://img.shields.io/badge/release-v0.3.3--beta-f0ad4e?style=for-the-badge)](#compatibility)
[![Buy Me a Coffee](https://img.shields.io/badge/Buy_Me_a_Coffee-Support-FFDD00?style=for-the-badge&logo=buymeacoffee&logoColor=000000)](https://buymeacoffee.com/jakubrolkab)

[Download GUI installer](#download--install-gui) · [Compatibility](#compatibility) · [How it works](#how-it-works) · [Limitations](#known-limitations) · [Support](#support-development)

</div>

---

> [!IMPORTANT]
> **Experimental community project.** The patcher has been successfully tested on **Apple M4, macOS 26.5.2**, with the Steam macOS game build **Unity 4.2.2f1 (54f0fc09defb)**. Compatibility with other macOS versions and Apple Silicon models is not yet confirmed. No game or Unity binaries are included.

## Why this exists

The original *Shadowrun Returns* macOS executable is a 32-bit Intel (`i386`) binary. Modern macOS cannot launch 32-bit applications; Rosetta 2 supports Intel **64-bit** applications, not 32-bit ones.

Fortunately, the game data was made with Unity **4.2.2f1**, whose official macOS installer includes a universal 32/64-bit standalone player. This patcher builds a **separate copy** of the game using that compatible runtime and its Mono libraries.

```text
Original macOS build                  Patched build
┌────────────────────────┐          ┌─────────────────────────┐
│ Unity 4.2.2f1 — i386   │          │ Unity 4.2.2f1 — x86_64  │
│ Cannot start on M-series│   →     │ Rosetta 2 → Apple Silicon│
│ Original game content  │          │ Original game content   │
└────────────────────────┘          └─────────────────────────┘
```

## Compatibility

| Feature | Apple M4 / macOS 26.5.2 |
| --- | --- |
| Launch from Finder | ✅ Tested |
| Main menu | ✅ Tested |
| Start campaign | ✅ Tested |
| Gameplay | ✅ Tested |
| Save and load | ✅ Tested |
| Saves after restarting game | ✅ Tested |
| Steam Cloud / achievements | ⚠️ Unavailable or not verified |
| Other Apple Silicon Macs | 🧪 Needs testing |

### Known limitations

- The original Steam native plugins `steamwrap` and `SteamAPIWrap` are 32-bit; the 64-bit player cannot load them. The observed log says **“Cloud disabled, Steam not available.”**
- This is a compatibility patch, not a native ARM64 port. Rosetta 2 is required.
- The game's old OpenGL rendering path and macOS compatibility may vary between machines.
- The installer requires the original macOS game build using Unity **4.2.2f1** and the matching official Unity 4.2.2 DMG. Other game builds are intentionally refused.
- Full-campaign stability, all third-party content and editor integration have not been verified.

## Download & install (GUI)

**Recommended for most users:** download the ready-to-run macOS app from the **v0.3.3-beta** release. You do **not** need to build the installer, use Terminal, or manually extract Unity.

### [⬇ Download the GUI installer — v0.3.3-beta](https://github.com/Kub0wy/shadowrun-returns-apple-silicon/releases/tag/v0.3.3-beta)

In the release's **Assets**, choose:

`Shadowrun-Returns-Apple-Silicon-Patcher-v0.3.3-beta-macOS.zip`

> [!TIP]
> Use the ZIP from **Release Assets**, not the automatically generated “Source code (zip)” archive. Source archives contain repository source code, not the ready-to-run app. If the release asset is not listed yet, the GUI release is not ready to download.

### Step-by-step

1. Install a legitimate **macOS** copy of *Shadowrun Returns* (tested with the Steam build using Unity 4.2.2f1).
2. Download the [official Unity 4.2.2 macOS DMG](https://beta.unity3d.com/download/unity-4.2.2.dmg). **Do not install Unity**—the patcher extracts the required runtime directly from this file.
3. Download the GUI installer ZIP under **Release Assets**, unzip it, and open **Shadowrun Returns Apple Silicon Patcher.app**.
4. Select the game's installation folder (the folder containing `Shadowrun.app`).
5. Select the downloaded `unity-4.2.2.dmg` file and an existing destination folder.
6. Run the patch. The installer shows its current stage, extracts Unity automatically, makes a separate game copy, signs it, and cleans up temporary extraction files.
7. Open the resulting `Shadowrun-AppleSilicon.app` from Finder.

**Your original Steam game and downloaded Unity DMG remain unchanged.** A separate patched app is created in the chosen destination. Temporary extraction files are cleaned up after successful installation and typical handled failures; unexpected process termination can leave temporary files behind.

> [!NOTE]
> The app is **ad-hoc signed, not Apple-notarized**. macOS may show a security warning on another computer. Review the app's origin, then use the system's **Open Anyway** workflow in Privacy & Security if you trust it. Do not broadly disable Gatekeeper.

### GUI features in v0.3.3-beta

- Guided macOS installer with project icon
- Stage-based installation progress (not an accurate per-byte percentage)
- Automatic extraction from the official Unity 4.2.2 DMG
- Isolated, patched game copy and ad-hoc signing
- Cleanup on success and common handled errors
- Original game installation is not overwritten

---

## Advanced / command-line installation

The following is an alternative for developers and troubleshooting. The GUI above is the recommended path.


### 1. Get the game and matching Unity runtime

- Install your legally obtained **macOS** copy of *Shadowrun Returns*.
- Obtain the official **Unity 4.2.2** macOS installer from Unity's archive: [Unity 4.2.2 DMG](https://beta.unity3d.com/download/unity-4.2.2.dmg).
- The legacy installer is provided by Unity, **not this repository**. Do **not** install or run the outdated editor; extract its assets.
- From `Unity.pkg` in the mounted DMG, extract `Unity.pkg/Payload` and unpack it to a dedicated folder. For example:

```bash
mkdir -p "$HOME/ShadowrunUnity/Extracted"
cd "$HOME/ShadowrunUnity"
xar -xf "/Volumes/Unity Installer/Unity.pkg" "Unity.pkg/Payload"
cd Extracted
gzip -dc ../Unity.pkg/Payload | cpio -idm
```

> [!NOTE]
> Your mounted volume might be named `Unity Installer 1` instead of `Unity Installer`. Check `ls /Volumes/` and adjust the path. Unpacking the legacy package consumes several GB of disk space. If the payload compression differs, inspect it rather than executing unknown scripts.

The Unity path for the patcher will be:

```text
~/ShadowrunUnity/Extracted/Unity/Unity.app
```

### 2. Download the patcher

Clone this repository:

```bash
git clone https://github.com/Kub0wy/shadowrun-returns-apple-silicon.git
cd shadowrun-returns-apple-silicon
```

Or download the repository ZIP using GitHub's **Code → Download ZIP**.

### 3. Run the patcher

```bash
bash scripts/patch.sh \
  --game "/path/to/SteamLibrary/steamapps/common/Shadowrun Returns" \
  --unity "$HOME/ShadowrunUnity/Extracted/Unity/Unity.app" \
  --output "$HOME/Desktop"
```

The script creates `Shadowrun-AppleSilicon.app` in the output folder. Double-click it in Finder. It **never modifies the original Steam installation** and refuses to overwrite an existing output app.

If using the downloaded ZIP, open Terminal in the unpacked repository or use the complete path to `scripts/patch.sh`.

### Run with a diagnostic log

```bash
arch -x86_64 "$HOME/Desktop/Shadowrun-AppleSilicon.app/Contents/MacOS/Shadowrun" -logFile -
```

If you encounter an issue, include your Mac model, macOS version, game build, patcher output, and the relevant part of your log when [opening an issue](https://github.com/Kub0wy/shadowrun-returns-apple-silicon/issues). Please don't upload proprietary game or Unity files.

## How it works

1. Checks for macOS, a game installation, and the exact Unity build `4.2.2f1 (54f0fc09defb)`.
2. Verifies that the replacement Unity Player and Mono dynamic libraries contain `x86_64`.
3. Copies `Shadowrun.app` into a temporary working directory.
4. Replaces the executable and embedded Mono runtime with files from the official Unity installation.
5. Moves the legacy Steam `installscript_osx.vdf` out of the app root if needed for modern code-signing rules.
6. Applies and verifies an ad-hoc macOS signature, then moves the completed app into the requested output directory.

The source app and user saves are not touched by the patcher.

## Project status & roadmap

- [x] Identify original 32-bit Unity build
- [x] Verify matching Unity 4.2.2f1 standalone player supports x86_64
- [x] Launch successfully on Apple M4
- [x] Test campaign start, save, load and restart
- [x] Independent path-based beta patcher
- [ ] Test on additional M1/M2/M3/M4 Macs and macOS releases
- [ ] Improve Steam integration where technically feasible
- [x] Graphical installer and automated Unity extraction (v0.3.3-beta)
- [ ] Stable 1.0 release after broader testing

## Legal and credits

**Unofficial fan compatibility tool.** Not affiliated with or endorsed by Harebrained Schemes, Unity Technologies, Valve, or the relevant rights holders. *Shadowrun* and related names are trademarks of their owners.

The release includes an installer app containing patching logic, but **no proprietary game or Unity engine binaries**. You must provide your own legitimately acquired game and official Unity 4.2.2 DMG. The original project script is licensed under the [MIT License](LICENSE), which does not apply to game assets or Unity binaries.

Built on the documented approach to upgrading Unity-based macOS games with their matching 64-bit players; see [mac-gaming-guides](https://github.com/boggydigital/mac-gaming-guides/blob/main/common/unity-porting.md).

## Support development

If this project helped you play *Shadowrun Returns* on your Mac, you can support further compatibility testing and improvements:

### [☕ Buy Me a Coffee — jakubrolkab](https://buymeacoffee.com/jakubrolkab)

Bug reports, reproducible test results, documentation corrections and pull requests are equally appreciated.

---

<div align="center">

**Shadowrun Returns · Apple Silicon Compatibility Patch**

Made with care for the Mac gaming community. · [Support the project ☕](https://buymeacoffee.com/jakubrolkab)

</div>
