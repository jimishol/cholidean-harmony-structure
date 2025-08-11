1. Click on Releases on the right screen. Click on Assets where windows users probably will download .zip file. Move it where cholidean-structure want to build e.g. C:\Users\username\ A directory like cholidean-harmony-structure-0.1.0-alpha will be created.

Unzip. (zip can be deleted) 

2. fluidsynth      
2.1 https://github.com/FluidSynth/fluidsynth/releases -> download zip -> unxip in project's directory e.g. in cholidean-harmony-structure-0.1.0-alpha\ There will be created lib\ include\ and bin\ directories (Anyway anyone is free to unzip fluidsynth anywhere he likes) Excecutable fluidsynth is inside bin\ directory. (Execute it if you like just to type "help" or "help player" to see brief explanation of usefull commands) 
   
2.2 sounfonts 
fluidsynth zip does not include soundsfonts. Very good are the https://github.com/Jacalz/fluid-soundfont/blob/master/original-files/FluidR3_GM.sf2 ("Download raw file" right of the screen)
Move them in project's folder e.g. cholidean-harmony-structure-0.1.0-alpha\

3. winPTY
I found easiest to download from https://sourceforge.net/projects/pcpu/files/Windows/Winpty-0.4.3-64-bits.exe/download
Installer is autodownloaded, double click to install it. Allow installer to download files, at 100% you will think it stucked but no. Wait few minutes and eventually installation eill be finished. A rebbot will be asked.

4.
In https://github.com/love2d/love go right of screen into releases -> pick your preffered installer e.g. https://github.com/love2d/love/releases/download/11.5/love-11.5-win64.exe download and double click to install. 
 
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
