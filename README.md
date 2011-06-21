# Audio in iOS Demo Projects

Three projects created to demo major sound APIs available to developers
in iOS. Used in talk given by me to the [Suncoast iPhone App
Developers](http://www.meetup.com/Suncoast-iPhone-App-Developers/).
on June 21, 2011. It should be obvious from the word "demo" used
throughout that these apps are NOT production-ready and often lack proper error
checking and handling for the sake of readability.

# Projects

Projects 0 and 1 each have multiple demos. Within the project, the demos are in
separate groups.

### Project 0

1. System Sounds: Sounds, alerts, and vibrations for short sound files using
   AudioToolbox's SystemSoundID.

2. AVAudioPlayer: Plays MP3 music file using AVAudioPlayer. Also demonstrates
   Audio Session config, audio backgrounding, and remote control events.

3. AVAudioRecorder: Basic demonstration of recording and playing back to CAF
   file.

### Project 1

1. Picker Demo: Allows user to choose and play a custom playlist of iPod
   content using MPMediaPickerController.

2. Playlist Demo: Demonstrates working with the iPod library programmatically
   (as opposed to using picker) by creating a custom grid of playlist views.
Uses same player as picker demo (PlayerViewController).

### Project 2

Demonstrates custom audio mixing using Audio Units. MixerHost class is adapted
from Apple's MixerHost demo app.


# License

The MIT License (MIT)
Copyright (c) 2011 Barry Ezell

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
