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
