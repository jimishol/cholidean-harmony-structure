# SoundFonts Directory

This folder is provided as a **convenience**—you don’t have to use it.  

• To load a SoundFont placed in your project **root**, simply set:  
```lua
M.soundfonts = "YourFile.sf2"
```  

• If you prefer to keep things organized, drop your `.sf2` file here and use:  
```lua
M.soundfonts = "soundfonts/YourFile.sf2"
```  
Either approach works on all platforms. LÖVE will read the file via its virtual filesystem provided it is located within the project’s root directory or one of its subfolders, and the backend will then dump it to a properly escaped OS path for Fluidsynth.

### File Size Guidelines  
- **< 500MB**: Generally safe to embed in project (tested: 142MB FluidR3_GM.sf2)  
- **≥ 500MB**: Consider using system defaults to avoid `dumpToTemp()` delays  
  
### System Resource Management  
- Disable PipeWire filter-chains during MIDI playback  
- Large SoundFonts require significant CPU for real-time synthesis  
- CPU contention causes audible jitter and timing issues  
  
### Recommended Configuration for Large Files  
For SoundFonts ≥ 500MB:  
1. Set `M.soundfonts = ""` in `src/constants.lua`  
2. Configure FluidSynth system defaults  
3. Ensure adequate CPU resources are available
