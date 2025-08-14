# Cholidean Harmony Structure

Cholidean Harmony Structure is a tool that bridges 12-tone equal temperament [12ET](https://en.wikipedia.org/wiki/12_equal_temperament) music and a two-dimensional surface strip curved in three-dimensional space to fit the surface of an [umbilic torus](https://en.wikipedia.org/wiki/Umbilic_torus). Its integration with [FluidSynth](https://github.com/FluidSynth/fluidsynth), as a MIDI backend player, demonstrates a powerful method for visualizing and exploring harmony theories.

## Installation Prerequisites and Steps 🚀

This project is built with LÖVE [Love2D](https://love2d.org/) and uses FluidSynth for MIDI playback. It runs best on Linux, but Windows support is straightforward. macOS is untested, though basic usage may work.

---

### 🐧 Linux

If you're on Linux and have LÖVE installed,
```
sudo zypper install love
```

 running from project's ROOT directory is simple:

love .

To enable MIDI playback, install FluidSynth via your package manager:
```
sudo zypper install fluidsynth
```
Then download the SoundFont `FluidR3_GM.sf2` from:
https://github.com/Jacalz/fluid-soundfont/blob/master/original-files/FluidR3_GM.sf2  
(use “Download raw file”) and place it in project's root or better install them, if your repository include them,
```
sudo zypper install fluid-soundfont-gm
```
There is no need to place sounfonts in project's root in that case.

---

### 🍎 macOS (Untested)

LÖVE and FluidSynth are available via Homebrew:

brew install love  
brew install fluidsynth

You can try running the project with:

love .

Note: macOS support is currently unverified. This project was built with love and determination by a non-developer, with lots of trial, error, and guidance. Contributions or feedback from macOS users—especially developers—are warmly welcomed to help improve compatibility and ease of use.

---

### 🪟 Windows

Before running the project on Windows, make sure you have a machine or VM with real GPU support, 3D acceleration, and OpenGL enabled. Without hardware acceleration, you’ll encounter a black screen and no audio output.

1. **Prepare the Project Directory**  
   - Download or clone your project release zip (e.g. `cholidean-harmony-structure-0.1.0-alpha.zip`).  
   - Unzip it anywhere you like, for example:  
     C:\Users\<YourUsername>\cholidean-harmony-structure-0.1.0-alpha  

2. **Install LÖVE (Love2D)**  
   - Visit https://love2d.org/ and download the Windows zip (portable version).  
   - Unzip to a folder of your choice, for example:  
     C:\Users\<YourUsername>\love-11.5-win64  
   - Move all contents of LÖVE folder (after all you can recreate them from the .zip file) into Project's Directory.  
   - After this step, `main.lua`, `conf.lua`, and any other project assets should sit next to `love.exe`.

3. **Install FluidSynth**  
     Download the binaries  
      - Go to https://github.com/FluidSynth/fluidsynth/releases and grab the latest Windows zip.  
      - Unzip it into your Project's Directory (same place as `main.lua`). This will create lib\`, `include\`, and `bin\`subfolders in it.

4. **Add SoundFonts**  
   - FluidSynth doesn’t ship with a default SoundFont.  
   - Download `FluidR3_GM.sf2` from:  
     https://github.com/Jacalz/fluid-soundfont/blob/master/original-files/FluidR3_GM.sf2  
     (use “Download raw file”)  
   - Place `FluidR3_GM.sf2` in your Project's Directory (next to `main.lua`).

5. **Install Git for Windows (a necessity for winpty)**  
   - Download Git for Windows from https://github.com/git-for-windows/git/releases (e.g. `v2.50.1.windows.1`). Scroll down to find assets and pick the latest installer.
    
   - Install and reboot your machine.  
   - Open **Git Bash**, cd into Project's Directory:  
   - Launch the game with console output enabled:  
     ./love.exe --console .

   - You should see no errors in the console, and keyboard shortcuts like Ctrl+Q will work to quit.

**Known Issue:**  
There is no sound, so no activity from notes ON/OFF.

---

## Prerequisites

If you haven’t already installed the project via Releases, this project uses Git Large File Storage (LFS) to manage assets (normal maps, textures, etc.). Before you clone, build, or contribute, make sure Git LFS is installed and initialized:

```bash
# Install Git LFS (once per machine):

# macOS (Homebrew)
brew install git-lfs

# Windows (Chocolatey)
choco install git-lfs

# Debian/Ubuntu
sudo apt-get install git-lfs

# Initialize Git LFS
git lfs install
```
## License 📝

This project is licensed under the **GNU General Public License v3.0**.  
You can find the full license text in the [LICENSE](LICENSE) file.

---

## Third-Party Licenses 📦

This project includes third-party assets that are distributed under their respective license terms.  
Please refer to the individual files in the `THIRD_PARTY_LICENSES/` directory for full details:

| Asset Type                  | License File |
|----------------------------|--------------|
| 3D Engine components        | [3dreamengine.md](THIRD_PARTY_LICENSES/3dreamengine.md) |
| Material textures & HDRIs  | [materials.md](THIRD_PARTY_LICENSES/materials.md) |
| MIDI files                  | [midis.md](THIRD_PARTY_LICENSES/midis.md) |

---

## Acknowledgments 🙏

This project took shape thanks to the insight and encouragement of [**E.... D...... V...**](https://github.com/USERNAME).

Although the idea had been explored by 20th‑century music–math theorists, it was only when E.D.V. encountered the concept that he immediately recognized its potential for new approaches in 12ET harmony. He urged me to share it more widely and encouraged me to bring it into academic and creative circles. 

That encouragement transformed a dormant idea into a living project. From OpenSCAD to MeshLab, to Blender, to 3DreamEngine, to MIDI events, each stage brought new challenges and discoveries. Without E.D.V.’s vision and determination, this journey might never have begun.
