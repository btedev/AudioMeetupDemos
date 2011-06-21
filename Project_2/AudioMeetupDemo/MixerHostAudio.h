/*
    File: MixerHostAudio.h
Abstract: Audio object: Handles all audio tasks for the application.
 Version: 1.0

*/


#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

#define FILE_COUNT  6
#define BUS_COUNT   18  //Reduce this to low number to see how available busses affects playing multiple notes simultaneously.                    
                      
// Data structure that defines a single audio file, related to a given tone
typedef struct {
    AudioUnitSampleType *audioData;         // the complete left (or mono) channel of audio data read from an audio file
    UInt32               frameCount;        // the total number of frames in the audio data
    int                  noteIdx;            // note index (i.e., a single key)
} fileStruct;

// Data structure for mono or stereo sound, to pass to the application's render callback function, 
//    which gets invoked by a Mixer unit input bus when it needs more audio to play.
typedef struct {
    AudioUnitSampleType     *audioData;             // the complete left (or mono) channel of audio data read from an audio file
    UInt32                  frameCount;             // the total number of frames in the audio data
    UInt32                  sampleNumber;           // the next audio sample to play
    BOOL                    hasAudio;               // 
} soundStruct, *soundStructPtr;

@interface MixerHostAudio : NSObject <AVAudioSessionDelegate> {

    Float64                         graphSampleRate;
    CFURLRef                        sourceURLArray[FILE_COUNT];
    soundStruct                     soundStructArray[BUS_COUNT];
    fileStruct                      fileStructArray[FILE_COUNT];

    // Before using an AudioStreamBasicDescription struct you must initialize it to 0. However, because these ASBDs
    // are declared in external storage, they are automatically initialized to 0.
    AudioStreamBasicDescription     monoStreamFormat;
    AUGraph                         processingGraph;
    BOOL                            playing;
    BOOL                            interruptedDuringPlayback;
    AudioUnit                       mixerUnit;
}

//@property (readwrite)           AudioStreamBasicDescription stereoStreamFormat;
@property (readwrite)           AudioStreamBasicDescription monoStreamFormat;
@property (readwrite)           Float64                     graphSampleRate;
@property (getter = isPlaying)  BOOL                        playing;
@property                       BOOL                        interruptedDuringPlayback;
@property                       AudioUnit                   mixerUnit;

- (void) obtainSoundFileURLs;
- (void) setupAudioSession;
- (void) setupMonoStreamFormat;
- (BOOL) playNote:(int)noteIdx;

- (void) readAudioFilesIntoMemory;

- (void) configureAndInitializeAudioProcessingGraph;
- (void) startAUGraph;
- (void) stopAUGraph;
- (void) setMixerOutputGain: (AudioUnitParameterValue) outputGain;

- (void) printASBD: (AudioStreamBasicDescription) asbd;
- (void) printErrorMessage: (NSString *) errorString withStatus: (OSStatus) result;

@end


