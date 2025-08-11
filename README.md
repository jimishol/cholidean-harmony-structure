Cluck on Releases on the right screen. 

Open File Explorer
    You can press Windows + E or click the folder icon on the taskbar.
Navigate to the location where you want application to be
Right-click in the blank sp
    In the folder area, right-click and choose New > Folder.
Name your folder
    Harmony Structure (or whatever you like) and press Enter.
      
https://github.com/FluidSynth/fluidsynth/releases -> download zip -> move zip inside the floder you created e.g. Harmony Structure
Unzip there. The excecutable is Inside fluidsynth-...downloaded_version...\bin\fluidsynth
It does not include soundsfonts. Grab from https://github.com/FluidSynth/fluidsynth/blob/master/sf2/VintageDreamsWaves-v2.sf2 and right of screen Download raw file or from wherever you like. Very good are the https://github.com/Jacalz/fluid-soundfont/blob/master/original-files/FluidR3_GM.sf2
Move them in the same file e.g. Harmony Structure.

(you can check it is working by Command Prompt.
Shift+RMB in the folder e.g Harmony Structure, choose Open Power Shell here. give something like (don't forget TAB can complete what you are trying to write and make typing much easier)  .\fluidsynth-2.4.7-win10-x64\bin\fluidsynth.exe .\FluidR3_GM.sf2 '.\beethoven_symphony_5_1_(c)galimberti.mid'
beethoven_symphony_5_1_(c)galimberti.mid was downloaded from assets/
 subfolder the same way

In https://github.com/love2d/love go right of screen into releases -> pick your preffered installer e.g. https://github.com/love2d/love/releases/download/11.5/love-11.5-win64.exe download and double click to install
 
## Prerequisites

This project uses Git Large File Storage (LFS) to manage big binary assets (normal-maps, textures, etc.).  
Before you clone, build or contribute, make sure you have Git LFS installed and initialized:

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
