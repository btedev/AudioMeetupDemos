/*
 File: MixerHostAudio.m
 Abstract: Audio object: Handles all audio tasks for the application.
 
 BTE: this is a modified version of Apple's MixerHostAudio file from
 the MixerHost demo app. The original creates two buses on the mixer, each dedicated
 to playing one looped audio file. This creates BUS_COUNT soundStructs ("buses") without dedicated
 sounds. The sounds are read separately into an array of size FILE_COUNT. When the user
 requests a sound be played, the playNote: method attemps to assign a sound buffer to
 an available bus. The bus plays back the entire buffer via repeated calls to  
 inputRenderCallback. It then re-enters the pool of available buses.
 
 */

#import "MixerHostAudio.h"

#pragma mark Mixer input bus render callback

//    This callback is invoked each time a Multichannel Mixer unit input bus requires more audio
//        samples. In this app, the mixer unit has two input buses. Each of them has its own render 
//        callback function and its own interleaved audio data buffer to read from.
//
//    This callback is written for an inRefCon parameter that can point to two noninterleaved 
//        buffers (for a stereo sound) or to one mono buffer (for a mono sound).
//
//    Audio unit input render callbacks are invoked on a realtime priority thread (the highest 
//    priority on the system). To work well, to not make the system unresponsive, and to avoid 
//    audio artifacts, a render callback must not:
//
//        * allocate memory
//        * access the file system or a network connection
//        * take locks
//        * waste time
//
//    In addition, it's usually best to avoid sending Objective-C messages in a render callback.
//
//    Declared as AURenderCallback in AudioUnit/AUComponent.h. See Audio Unit Component Services Reference.
static OSStatus inputRenderCallback (
                                     
                                     void                        *inRefCon,      // A pointer to a struct containing the complete audio data 
                                     //    to play, as well as state information such as the  
                                     //    first sample to play on this invocation of the callback.
                                     AudioUnitRenderActionFlags  *ioActionFlags, // Unused here. When generating audio, use ioActionFlags to indicate silence 
                                     //    between sounds; for silence, also memset the ioData buffers to 0.
                                     const AudioTimeStamp        *inTimeStamp,   // Unused here.
                                     UInt32                      inBusNumber,    // The mixer unit input bus that is requesting some new
                                     //        frames of audio data to play.
                                     UInt32                      inNumberFrames, // The number of frames of audio to provide to the buffer(s)
                                     //        pointed to by the ioData parameter.
                                     AudioBufferList             *ioData         // On output, the audio data to play. The callback's primary 
                                     //        responsibility is to fill the buffer(s) in the 
                                     //        AudioBufferList.
                                     ) {
    
    soundStructPtr    soundStructPointerArray   = (soundStructPtr) inRefCon;
    UInt32            frameTotalForSound        = soundStructPointerArray[inBusNumber].frameCount;
    
    // Declare variables to point to the audio buffers. Their data type must match the buffer data type.
    AudioUnitSampleType *dataInLeft;
    dataInLeft = soundStructPointerArray[inBusNumber].audioData;
    
    // Establish pointers to the memory into which the audio from the buffers should go. 
    AudioUnitSampleType *outSamplesChannelLeft;    
    outSamplesChannelLeft = (AudioUnitSampleType *) ioData->mBuffers[0].mData;
    
    //Copy data from the audioData bufferlist into the callback bufferlist (ioData) only if audioData exists, 
    //else memset ioData with 0's to indicate silence.
    if (soundStructPointerArray[inBusNumber].hasAudio == YES) {        
        
        // Get the sample number, as an index into the sound stored in memory,
        //    to start reading data from.
        UInt32 sampleNumber = soundStructPointerArray[inBusNumber].sampleNumber;
        
        // Fill the buffer or buffers pointed at by *ioData with the requested number of samples 
        //    of audio from the sound stored in memory.
        for (UInt32 frameNumber = 0; frameNumber < inNumberFrames; ++frameNumber) {       
            if (sampleNumber < frameTotalForSound) {
                outSamplesChannelLeft[frameNumber] = dataInLeft[sampleNumber];            
                sampleNumber++;
            } else {                   
                //End of input audio data. Remaining frames are silent.
                memset(&outSamplesChannelLeft[frameNumber], 0, sizeof(outSamplesChannelLeft[frameNumber]));
            }                
        }
        
        // Update the stored sample number so, the next time this callback is invoked, playback resumes 
        //    at the correct spot unless the end of the sound file has been reached.
        if (sampleNumber < frameTotalForSound) {
            soundStructPointerArray[inBusNumber].sampleNumber = sampleNumber;
        } else {          
            soundStructPointerArray[inBusNumber].hasAudio = NO;
        }    
    } else {
        //return silence
        for (UInt32 frameNumber = 0; frameNumber < inNumberFrames; ++frameNumber) { 
            memset(&outSamplesChannelLeft[frameNumber], 0, sizeof(outSamplesChannelLeft[frameNumber]));
        }
    }
    
    return noErr;
}

#pragma mark -
@implementation MixerHostAudio

@synthesize monoStreamFormat;           // mono format for use in buffer and mixer input 
@synthesize graphSampleRate;            // sample rate to use throughout audio processing chain
@synthesize mixerUnit;                  // the Multichannel Mixer unit
@synthesize playing;                    // Boolean flag to indicate whether audio is playing or not
@synthesize interruptedDuringPlayback;  // Boolean flag to indicate whether audio was playing when an interruption arrived

#pragma mark -
#pragma mark Initialize

// Get the app ready for playback.
- (id) init {
    
    self = [super init];
    
    if (!self) return nil;
    
    self.interruptedDuringPlayback = NO;
    
    [self setupAudioSession];
    [self obtainSoundFileURLs];
    //[self setupStereoStreamFormat];
    [self setupMonoStreamFormat];
    [self readAudioFilesIntoMemory];
    [self configureAndInitializeAudioProcessingGraph];
    
    return self;
}


#pragma mark -
#pragma mark Audio set up

- (void) setupAudioSession {
    
    AVAudioSession *mySession = [AVAudioSession sharedInstance];
    
    // Specify that this object is the delegate of the audio session, so that
    //    this object's endInterruption method will be invoked when needed.
    [mySession setDelegate: self];
    
    // Assign the Playback category to the audio session.
    NSError *audioSessionError = nil;
    [mySession setCategory: AVAudioSessionCategoryPlayback
                     error: &audioSessionError];
    
    if (audioSessionError != nil) {
        
        NSLog (@"Error setting audio session category.");
        return;
    }
    
    // Request the desired hardware sample rate.
    self.graphSampleRate = 44100.0;    // Hertz
    
    [mySession setPreferredHardwareSampleRate: graphSampleRate
                                        error: &audioSessionError];
    
    if (audioSessionError != nil) {
        
        NSLog (@"Error setting preferred hardware sample rate.");
        return;
    }
    
    // Activate the audio session
    [mySession setActive: YES
                   error: &audioSessionError];
    
    if (audioSessionError != nil) {
        
        NSLog (@"Error activating audio session during initial setup.");
        return;
    }
    
    // Obtain the actual hardware sample rate and store it for later use in the audio processing graph.
    self.graphSampleRate = [mySession currentHardwareSampleRate];    
}

//Note: sound files are courtesy of http://www.freesound.org/usersViewSingle.php?id=2065674
//and made available under the Creative Commons Sampling Plus 1.0 License
//http://creativecommons.org/licenses/sampling+/1.0/
//
- (void) obtainSoundFileURLs {
    
    for(int i=0; i<FILE_COUNT; i++) {
        NSURL *url = [[NSBundle mainBundle] URLForResource:[NSString stringWithFormat:@"vib_%i",i] withExtension:@"aiff"];
        
        // ExtAudioFileRef objects expect CFURLRef URLs, so cast to CRURLRef here
        sourceURLArray[i] = (CFURLRef) [url retain];
    }
}

- (void) setupMonoStreamFormat {
    
    // The AudioUnitSampleType data type is the recommended type for sample data in audio
    //    units. This obtains the byte size of the type for use in filling in the ASBD.
    size_t bytesPerSample = sizeof (AudioUnitSampleType);
    
    // Fill the application audio format struct's fields to define a linear PCM, 
    //        stereo, noninterleaved stream at the hardware sample rate.
    monoStreamFormat.mFormatID          = kAudioFormatLinearPCM;
    monoStreamFormat.mFormatFlags       = kAudioFormatFlagsAudioUnitCanonical;
    monoStreamFormat.mBytesPerPacket    = bytesPerSample;
    monoStreamFormat.mFramesPerPacket   = 1;
    monoStreamFormat.mBytesPerFrame     = bytesPerSample;
    monoStreamFormat.mChannelsPerFrame  = 1;                  // 1 indicates mono
    monoStreamFormat.mBitsPerChannel    = 8 * bytesPerSample;
    monoStreamFormat.mSampleRate        = graphSampleRate;
    
    NSLog (@"The mono stream format for the \"beats\" mixer input bus:");
    [self printASBD: monoStreamFormat];
    
}


#pragma mark -
#pragma mark Read audio files into memory

- (void) readAudioFilesIntoMemory {
    
    for (int audioFile = 0; audioFile < FILE_COUNT; ++audioFile)  {
        
        NSLog (@"readAudioFilesIntoMemory - file %i", audioFile);
        
        // Instantiate an extended audio file object.
        ExtAudioFileRef audioFileObject = 0;
        
        // Open an audio file and associate it with the extended audio file object.
        OSStatus result = ExtAudioFileOpenURL (sourceURLArray[audioFile], &audioFileObject);
        
        if (noErr != result || NULL == audioFileObject) {[self printErrorMessage: @"ExtAudioFileOpenURL" withStatus: result]; return;}
        
        // Get the audio file's length in frames.
        UInt64 totalFramesInFile = 0;
        UInt32 frameLengthPropertySize = sizeof (totalFramesInFile);
        
        result =    ExtAudioFileGetProperty (
                                             audioFileObject,
                                             kExtAudioFileProperty_FileLengthFrames,
                                             &frameLengthPropertySize,
                                             &totalFramesInFile
                                             );
        
        if (noErr != result) {[self printErrorMessage: @"ExtAudioFileGetProperty (audio file length in frames)" withStatus: result]; return;}
        
        // Assign the frame count to the soundStructArray instance variable
        fileStructArray[audioFile].frameCount = totalFramesInFile;
        
        // Get the audio file's number of channels.
        AudioStreamBasicDescription fileAudioFormat = {0};
        UInt32 formatPropertySize = sizeof (fileAudioFormat);
        
        result =    ExtAudioFileGetProperty (
                                             audioFileObject,
                                             kExtAudioFileProperty_FileDataFormat,
                                             &formatPropertySize,
                                             &fileAudioFormat
                                             );
        
        if (noErr != result) {[self printErrorMessage: @"ExtAudioFileGetProperty (file audio format)" withStatus: result]; return;}
        
        UInt32 channelCount = fileAudioFormat.mChannelsPerFrame;
        
        // Allocate memory in the fileStructArray instance variable to hold the left channel, 
        //    or mono, audio data
        fileStructArray[audioFile].audioData = (AudioUnitSampleType *) calloc(totalFramesInFile, sizeof(AudioUnitSampleType));
        
        AudioStreamBasicDescription importFormat = {0};
        if (1 == channelCount) {           
            importFormat = monoStreamFormat;            
        } else {        
            NSLog (@"*** WARNING: File format not supported - wrong number of channels");
            ExtAudioFileDispose (audioFileObject);
            return;
        }
        
        // Assign the appropriate mixer input bus stream data format to the extended audio 
        //        file object. This is the format used for the audio data placed into the audio 
        //        buffer in the fileStruct data structure, which is in turn used in the 
        //        inputRenderCallback callback function.
        
        result =    ExtAudioFileSetProperty (
                                             audioFileObject,
                                             kExtAudioFileProperty_ClientDataFormat,
                                             sizeof (importFormat),
                                             &importFormat
                                             );
        
        if (noErr != result) {[self printErrorMessage: @"ExtAudioFileSetProperty (client data format)" withStatus: result]; return;}
        
        // Set up an AudioBufferList struct, which has two roles:
        //
        //        1. It gives the ExtAudioFileRead function the configuration it 
        //            needs to correctly provide the data to the buffer.
        //
        //        2. It points to the fileStructArray[audioFile].audioData buffer, so 
        //            that audio data obtained from disk using the ExtAudioFileRead function
        //            goes to that buffer
        
        // Allocate memory for the buffer list struct according to the number of 
        //    channels it represents.
        AudioBufferList *bufferList;
        
        bufferList = (AudioBufferList *) malloc (
                                                 sizeof (AudioBufferList) + sizeof (AudioBuffer) * (channelCount - 1)
                                                 );
        
        if (NULL == bufferList) {NSLog (@"*** malloc failure for allocating bufferList memory"); return;}
        
        // initialize the mNumberBuffers member
        bufferList->mNumberBuffers = channelCount;
        
        // initialize the mBuffers member to 0
        AudioBuffer emptyBuffer = {0};
        size_t arrayIndex;
        for (arrayIndex = 0; arrayIndex < channelCount; arrayIndex++) {
            bufferList->mBuffers[arrayIndex] = emptyBuffer;
        }
        
        // set up the AudioBuffer structs in the buffer list
        bufferList->mBuffers[0].mNumberChannels  = 1;
        bufferList->mBuffers[0].mDataByteSize    = totalFramesInFile * sizeof (AudioUnitSampleType);
        bufferList->mBuffers[0].mData            = fileStructArray[audioFile].audioData;
        
        // Perform a synchronous, sequential read of the audio data out of the file and
        //    into the soundStructArray[audioFile].audioData and (if stereo) .audioDataRight members.
        UInt32 numberOfPacketsToRead = (UInt32) totalFramesInFile;
        
        result = ExtAudioFileRead (
                                   audioFileObject,
                                   &numberOfPacketsToRead,
                                   bufferList
                                   );
        
        free (bufferList);
        
        if (noErr != result) {
            
            [self printErrorMessage: @"ExtAudioFileRead failure - " withStatus: result];
            
            // If reading from the file failed, then free the memory for the sound buffer.
            free (fileStructArray[audioFile].audioData);
            fileStructArray[audioFile].audioData = 0;            
            ExtAudioFileDispose (audioFileObject);            
            return;
        }
        
        NSLog (@"Finished reading file %i into memory", audioFile);
        
        // Dispose of the extended audio file object, which also
        //    closes the associated file.
        ExtAudioFileDispose (audioFileObject);
    }
}


#pragma mark -
#pragma mark Audio processing graph setup

// This method performs all the work needed to set up the audio processing graph:

// 1. Instantiate and open an audio processing graph
// 2. Obtain the audio unit nodes for the graph
// 3. Configure the Multichannel Mixer unit
//     * specify the number of input buses
//     * specify the output sample rate
//     * specify the maximum frames-per-slice
// 4. Initialize the audio processing graph

- (void) configureAndInitializeAudioProcessingGraph {
    
    NSLog (@"Configuring and then initializing audio processing graph");
    OSStatus result = noErr;
    
    //............................................................................
    // Create a new audio processing graph.
    result = NewAUGraph (&processingGraph);
    
    if (noErr != result) {[self printErrorMessage: @"NewAUGraph" withStatus: result]; return;}
    
    
    //............................................................................
    // Specify the audio unit component descriptions for the audio units to be
    //    added to the graph.
    
    // I/O unit
    AudioComponentDescription iOUnitDescription;
    iOUnitDescription.componentType          = kAudioUnitType_Output;
    iOUnitDescription.componentSubType       = kAudioUnitSubType_RemoteIO;
    iOUnitDescription.componentManufacturer  = kAudioUnitManufacturer_Apple;
    iOUnitDescription.componentFlags         = 0;
    iOUnitDescription.componentFlagsMask     = 0;
    
    // Multichannel mixer unit
    AudioComponentDescription MixerUnitDescription;
    MixerUnitDescription.componentType          = kAudioUnitType_Mixer;
    MixerUnitDescription.componentSubType       = kAudioUnitSubType_MultiChannelMixer;
    MixerUnitDescription.componentManufacturer  = kAudioUnitManufacturer_Apple;
    MixerUnitDescription.componentFlags         = 0;
    MixerUnitDescription.componentFlagsMask     = 0;
    
    
    //............................................................................
    // Add nodes to the audio processing graph.
    NSLog (@"Adding nodes to audio processing graph");
    
    AUNode   iONode;         // node for I/O unit
    AUNode   mixerNode;      // node for Multichannel Mixer unit
    
    // Add the nodes to the audio processing graph
    result =    AUGraphAddNode (
                                processingGraph,
                                &iOUnitDescription,
                                &iONode);
    
    if (noErr != result) {[self printErrorMessage: @"AUGraphNewNode failed for I/O unit" withStatus: result]; return;}
    
    
    result =    AUGraphAddNode (
                                processingGraph,
                                &MixerUnitDescription,
                                &mixerNode
                                );
    
    if (noErr != result) {[self printErrorMessage: @"AUGraphNewNode failed for Mixer unit" withStatus: result]; return;}
    
    
    //............................................................................
    // Open the audio processing graph
    
    // Following this call, the audio units are instantiated but not initialized
    //    (no resource allocation occurs and the audio units are not in a state to
    //    process audio).
    result = AUGraphOpen (processingGraph);
    
    if (noErr != result) {[self printErrorMessage: @"AUGraphOpen" withStatus: result]; return;}
    
    
    //............................................................................
    // Obtain the mixer unit instance from its corresponding node.
    
    result =    AUGraphNodeInfo (
                                 processingGraph,
                                 mixerNode,
                                 NULL,
                                 &mixerUnit
                                 );
    
    if (noErr != result) {[self printErrorMessage: @"AUGraphNodeInfo" withStatus: result]; return;}
    
    
    //............................................................................
    // Multichannel Mixer unit Setup
    
    UInt32 busCount   = BUS_COUNT;    // bus count for mixer unit input
    
    NSLog (@"Setting mixer unit input bus count to: %lu", busCount);
    result = AudioUnitSetProperty (
                                   mixerUnit,
                                   kAudioUnitProperty_ElementCount,
                                   kAudioUnitScope_Input,
                                   0,
                                   &busCount,
                                   sizeof (busCount)
                                   );
    
    if (noErr != result) {[self printErrorMessage: @"AudioUnitSetProperty (set mixer unit bus count)" withStatus: result]; return;}
    
    
    NSLog (@"Setting kAudioUnitProperty_MaximumFramesPerSlice for mixer unit global scope");
    // Increase the maximum frames per slice allows the mixer unit to accommodate the
    //    larger slice size used when the screen is locked.
    UInt32 maximumFramesPerSlice = 4096;
    
    result = AudioUnitSetProperty (
                                   mixerUnit,
                                   kAudioUnitProperty_MaximumFramesPerSlice,
                                   kAudioUnitScope_Global,
                                   0,
                                   &maximumFramesPerSlice,
                                   sizeof (maximumFramesPerSlice)
                                   );
    
    if (noErr != result) {[self printErrorMessage: @"AudioUnitSetProperty (set mixer unit input stream format)" withStatus: result]; return;}
    
    
    // Attach the input render callback and context to each input bus
    for (UInt16 busNumber = 0; busNumber < busCount; ++busNumber) {
        
        // Setup the struture that contains the input render callback 
        AURenderCallbackStruct inputCallbackStruct;
        inputCallbackStruct.inputProc        = &inputRenderCallback;
        inputCallbackStruct.inputProcRefCon  = soundStructArray;
        
        NSLog (@"Registering the render callback with mixer unit input bus %u", busNumber);
        // Set a callback for the specified node's specified input
        result = AUGraphSetNodeInputCallback (
                                              processingGraph,
                                              mixerNode,
                                              busNumber,
                                              &inputCallbackStruct
                                              );
        
        if (noErr != result) {[self printErrorMessage: @"AUGraphSetNodeInputCallback" withStatus: result]; return;}
        
        NSLog (@"Setting mono stream format for mixer unit %u input bus",busNumber);
        result = AudioUnitSetProperty (
                                       mixerUnit,
                                       kAudioUnitProperty_StreamFormat,
                                       kAudioUnitScope_Input,
                                       busNumber,
                                       &monoStreamFormat,
                                       sizeof (monoStreamFormat)
                                       );
        
        if (noErr != result) {[self printErrorMessage: @"AudioUnitSetProperty (set mixer unit input bus stream format)" withStatus: result];return;}
    }
    
    NSLog (@"Setting sample rate for mixer unit output scope");
    // Set the mixer unit's output sample rate format. This is the only aspect of the output stream
    //    format that must be explicitly set.
    result = AudioUnitSetProperty (
                                   mixerUnit,
                                   kAudioUnitProperty_SampleRate,
                                   kAudioUnitScope_Output,
                                   0,
                                   &graphSampleRate,
                                   sizeof (graphSampleRate)
                                   );
    
    if (noErr != result) {[self printErrorMessage: @"AudioUnitSetProperty (set mixer unit output stream format)" withStatus: result]; return;}
    
    
    //............................................................................
    // Connect the nodes of the audio processing graph
    NSLog (@"Connecting the mixer output to the input of the I/O unit output element");
    
    result = AUGraphConnectNodeInput (
                                      processingGraph,
                                      mixerNode,         // source node
                                      0,                 // source node output bus number
                                      iONode,            // destination node
                                      0                  // desintation node input bus number
                                      );
    
    if (noErr != result) {[self printErrorMessage: @"AUGraphConnectNodeInput" withStatus: result]; return;}
    
    
    //............................................................................
    // Initialize audio processing graph
    
    // Diagnostic code
    // Call CAShow if you want to look at the state of the audio processing 
    //    graph.
    NSLog (@"Audio processing graph state immediately before initializing it:");
    CAShow (processingGraph);
    
    NSLog (@"Initializing the audio processing graph");
    // Initialize the audio processing graph, configure audio data stream formats for
    //    each input and output, and validate the connections between audio units.
    result = AUGraphInitialize (processingGraph);
    
    if (noErr != result) {[self printErrorMessage: @"AUGraphInitialize" withStatus: result]; return;}
}


#pragma mark -
#pragma mark Playback control

// Start playback
- (void) startAUGraph  {
    
    NSLog (@"Starting audio processing graph");
    OSStatus result = AUGraphStart (processingGraph);
    if (noErr != result) {[self printErrorMessage: @"AUGraphStart" withStatus: result]; return;}
    
    self.playing = YES;
}

// Stop playback
- (void) stopAUGraph {
    
    NSLog (@"Stopping audio processing graph");
    Boolean isRunning = false;
    OSStatus result = AUGraphIsRunning (processingGraph, &isRunning);
    if (noErr != result) {[self printErrorMessage: @"AUGraphIsRunning" withStatus: result]; return;}
    
    if (isRunning) {
        
        result = AUGraphStop (processingGraph);
        if (noErr != result) {[self printErrorMessage: @"AUGraphStop" withStatus: result]; return;}
        self.playing = NO;
    }
}

#pragma mark -
#pragma mark Note control methods

- (BOOL) playNote:(int)noteIdx {  
    
    //Find a bus that's not currently in use (if any)
    //and assign the selected sound to it. Playback will
    //begin the next time inputRenderCallback() fires.
    for (int i=0; i<BUS_COUNT; i++) {
        if (soundStructArray[i].hasAudio == NO) {
            soundStructArray[i].sampleNumber = 0;
            soundStructArray[i].frameCount = fileStructArray[noteIdx].frameCount;
            soundStructArray[i].audioData = fileStructArray[noteIdx].audioData;
            soundStructArray[i].hasAudio = YES;
            return YES;
        }
    }
    
    return NO;
}


// Set the mxer unit output volume
- (void) setMixerOutputGain: (AudioUnitParameterValue) newGain {
    
    OSStatus result = AudioUnitSetParameter (
                                             mixerUnit,
                                             kMultiChannelMixerParam_Volume,
                                             kAudioUnitScope_Output,
                                             0,
                                             newGain,
                                             0
                                             );
    
    if (noErr != result) {[self printErrorMessage: @"AudioUnitSetParameter (set mixer unit output volume)" withStatus: result]; return;}
    
}


#pragma mark -
#pragma mark Audio Session Delegate Methods
// Respond to having been interrupted. This method sends a notification to the 
//    controller object, which in turn invokes the playOrStop: toggle method. The 
//    interruptedDuringPlayback flag lets the  endInterruptionWithFlags: method know 
//    whether playback was in progress at the time of the interruption.
- (void) beginInterruption {
    
    NSLog (@"Audio session was interrupted.");
    
    if (playing) {
        
        self.interruptedDuringPlayback = YES;
        
        NSString *MixerHostAudioObjectPlaybackStateDidChangeNotification = @"MixerHostAudioObjectPlaybackStateDidChangeNotification";
        [[NSNotificationCenter defaultCenter] postNotificationName: MixerHostAudioObjectPlaybackStateDidChangeNotification object: self]; 
    }
}


// Respond to the end of an interruption. This method gets invoked, for example, 
//    after the user dismisses a clock alarm. 
- (void) endInterruptionWithFlags: (NSUInteger) flags {
    
    // Test if the interruption that has just ended was one from which this app 
    //    should resume playback.
    if (flags & AVAudioSessionInterruptionFlags_ShouldResume) {
        
        NSError *endInterruptionError = nil;
        [[AVAudioSession sharedInstance] setActive: YES
                                             error: &endInterruptionError];
        if (endInterruptionError != nil) {
            
            NSLog (@"Unable to reactivate the audio session after the interruption ended.");
            return;
            
        } else {
            
            NSLog (@"Audio session reactivated after interruption.");
            
            if (interruptedDuringPlayback) {
                
                self.interruptedDuringPlayback = NO;
                
                // Resume playback by sending a notification to the controller object, which
                //    in turn invokes the playOrStop: toggle method.
                NSString *MixerHostAudioObjectPlaybackStateDidChangeNotification = @"MixerHostAudioObjectPlaybackStateDidChangeNotification";
                [[NSNotificationCenter defaultCenter] postNotificationName: MixerHostAudioObjectPlaybackStateDidChangeNotification object: self]; 
                
            }
        }
    }
}


#pragma mark -
#pragma mark Utility methods

// You can use this method during development and debugging to look at the
//    fields of an AudioStreamBasicDescription struct.
- (void) printASBD: (AudioStreamBasicDescription) asbd {
    
    char formatIDString[5];
    UInt32 formatID = CFSwapInt32HostToBig (asbd.mFormatID);
    bcopy (&formatID, formatIDString, 4);
    formatIDString[4] = '\0';
    
    NSLog (@"  Sample Rate:         %10.0f",  asbd.mSampleRate);
    NSLog (@"  Format ID:           %10s",    formatIDString);
    NSLog (@"  Format Flags:        %10lu",    asbd.mFormatFlags);
    NSLog (@"  Bytes per Packet:    %10lu",    asbd.mBytesPerPacket);
    NSLog (@"  Frames per Packet:   %10lu",    asbd.mFramesPerPacket);
    NSLog (@"  Bytes per Frame:     %10lu",    asbd.mBytesPerFrame);
    NSLog (@"  Channels per Frame:  %10lu",    asbd.mChannelsPerFrame);
    NSLog (@"  Bits per Channel:    %10lu",    asbd.mBitsPerChannel);
}

- (void) printErrorMessage: (NSString *) errorString withStatus: (OSStatus) result {
    
    char resultString[5];
    UInt32 swappedResult = CFSwapInt32HostToBig (result);
    bcopy (&swappedResult, resultString, 4);
    resultString[4] = '\0';
    
    NSLog (
           @"*** %@ error: %%d%08X %4.4s\n",
           errorString,
           (char*) &resultString
           );
}


#pragma mark -
#pragma mark Deallocate

- (void) dealloc {
    
    for (int audioFile = 0; audioFile < FILE_COUNT; ++audioFile)  {    
        
        if (sourceURLArray[audioFile] != NULL) CFRelease (sourceURLArray[audioFile]);
        
        if (fileStructArray[audioFile].audioData != NULL) {
            free (fileStructArray[audioFile].audioData);
            fileStructArray[audioFile].audioData = 0;
        }
    }
    
    [super dealloc];
}

@end

