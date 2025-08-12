## Windows Testing Guide

Before running the project on Windows, make sure you have a machine or VM with real GPU support, 3D acceleration and OpenGL enabled. Without hardware acceleration you’ll encounter a black screen and no audio output.

1. Install LÖVE (Love2D)

   - Visit https://love2d.org/ and download the Windows zip (portable version).  
   - Unzip to a folder of your choice, for example:
     ```
     C:\Users\<YourUsername>\love-11.5-win64
     ```
   - You should now have `love.exe` alongside folders like `love-11.5-win64\`.

2. Prepare the Project Directory

   - Download or clone your project release zip (e.g. `cholidean-harmony-structure-0.1.0-alpha.zip`).  
   - Unzip it anywhere you like, for example:
     ```
     C:\Users\<YourUsername>\cholidean-harmony-structure-0.1.0-alpha
     ```
   - Copy all project files (including `main.lua`) into the same folder where `love.exe` lives:
     ```
     C:\Users\<YourUsername>\love-11.5-win64\
     ```
   - After this step, `main.lua`, `conf.lua` and any other project assets should sit next to `love.exe`.

3. Install FluidSynth

   3.1 Download the binaries  
   - Go to https://github.com/FluidSynth/fluidsynth/releases and grab the latest Windows zip.  
   - Unzip it into your project folder (same place as `main.lua`), creating subfolders `lib\`, `include\`, and `bin\`.  

   3.2 Configure the backend path  
   - Open `constants.lua` in your project and set:
     ```lua
     M.windowsBackendPath = "bin\\"
     ```
   - You can run `bin\fluidsynth.exe` manually (e.g. `fluidsynth.exe --help`) to verify it works.

4. Add SoundFonts

   - FluidSynth doesn’t ship with a default SoundFont.  
   - Download `FluidR3_GM.sf2` from https://github.com/Jacalz/fluid-soundfont/blob/master/original-files/FluidR3_GM.sf2 (use “Download raw file”).  
   - Place `FluidR3_GM.sf2` in your project root (next to `main.lua`).

5. Install Git for Windows (a necessity for winpty)

   - Download Git for Windows from https://github.com/git-for-windows/git/releases (e.g. `v2.50.1.windows.1`).  
   - Install and reboot your machine.  
   - Open **Git Bash**, cd into your LÖVE folder:
     ```bash
     cd /c/Users/<YourUsername>/love-11.5-win64
     ```
   - Launch the game with console output enabled:
     ```bash
     ./love.exe --console .
     ```
   - You should see no errors in the console, and keyboard shortcuts like Ctrl+Q will work to quit.

**Known Issue:**  
In a VM without proper GPU passthrough or 3D acceleration, you will get a black screen and no sound. For full functionality, test on a physical Windows machine or in a VM configured with a dedicated GPU.

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
## License

This project is licensed under the GNU General Public License v3.0.  
See [LICENSE](LICENSE) for the full text.

## Third-Party Licenses

The following third-party assets are included with this project under their own license terms.  
Please refer to the corresponding files in the `THIRD_PARTY_LICENSES/` directory for full details.

- 3D Engine components  
  [THIRD_PARTY_LICENSES/3dreamengine.md](THIRD_PARTY_LICENSES/3dreamengine.md)

- Material textures & HDRIs  
  [THIRD_PARTY_LICENSES/materials.md](THIRD_PARTY_LICENSES/materials.md)

- MIDI files  
  [THIRD_PARTY_LICENSES/midis.md](THIRD_PARTY_LICENSES/midis.md)
