//
//  ISpeechSDK+Compatibility.h
//  iSpeechSDK
//
//  Copyright (c) 2012 iSpeech, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <iSpeechSDK/iSpeechSDK.h>

enum {
	kISpeechErrorCodeUserCancelled = 300
};

#define ISpeechErrorDomain iSpeechErrorDomain

@interface ISpeechSDK : NSObject <ISSpeechSynthesisDelegate, ISSpeechRecognitionDelegate> {
	id speakingDelegate;
	id recognizeDelegate;
	
	ISSpeechSynthesis *activeSynthesis;
	ISSpeechRecognition *activeRecognition;
	
	NSString *recognizeResult;
	float recognizeConfidence;
	
	NSMutableArray *commandList;
	NSMutableDictionary *aliasList;
	
	BOOL enableSilenceDetection;
	
	BOOL hasRecordingUpdate;
}

- (id) ISpeechSetSpeakingDone:(id)delegate;

- (void) ISpeechSetVoice:(NSString *)voice;
- (NSString *)ISpeechVoice;

- (void) ISpeechSetLocale:(NSString *)locale;
- (NSString *)ISpeechLocale;

- (void) ISpeechSetModel:(NSString *)model;
- (NSString *)ISpeechModel;

- (void) ISpeechSetSpeed:(NSInteger)speed;
- (NSInteger) ISpeechSpeed;

- (BOOL) ISpeechSpeak:(NSString *)text;
- (BOOL) ISpeechSpeak:(NSString *)text error:(NSError **)errPtr;

- (void) ISpeechStopSpeaking;

- (BOOL) ISpeechIsSpeaking;

- (BOOL) ISpeechCancelListen;

- (NSString *) ISpeechGetRecognizeResult ;

- (float) ISpeechGetRecognizeConfidence ;

- (id) ISpeechSetRecognizeDone:(id)delegate;

/**
 * NOTE: In the new SDK, there is no customization of silence detection. All these methods do is turn it on or off.
 * 
 * Pass in a non-zero value for either seconds or duration to turn it on, and zero to turn it off.
 */
- (void) ISpeechSilenceDetectAfter:(NSTimeInterval)seconds forDuration:(NSTimeInterval)duration;

- (BOOL) ISpeechStartListen;
- (BOOL) ISpeechStartListenWithError:(NSError **)errPtr;

- (BOOL) ISpeechStopListenStartRecognize;

- (BOOL) ISpeechListenThenRecognizeWithTimeout:(NSTimeInterval)seconds;
- (BOOL) ISpeechListenThenRecognizeWithTimeout:(NSTimeInterval)seconds error:(NSError **)errPtr;

- (void) ISpeechAddRecognitionList:(NSArray *)strings;

- (void) ISpeechAddRecognitionAlias:(NSString *)aliasName forList:(NSArray *)strings;

- (void) ISpeechClearRecognitionList;

- (BOOL) ISpeechListenThenRecognize:(NSString *)stringOfWords separatedBy:(NSString *)wordSeparator withTimeout:(NSTimeInterval)seconds;
- (BOOL) ISpeechListenThenRecognize:(NSString *)stringOfWords separatedBy:(NSString *)wordSeparator withTimeout:(NSTimeInterval)seconds error:(NSError **)errPtr;

- (BOOL) ISpeechIsRecognizing;

- (void)ISSpeechSetExtraServerParameters:(NSString *)params;

+ (ISpeechSDK *) ISpeech:(NSString *)apiKey provider:(NSString *)provName application:(NSString *)appName useProduction:(BOOL)useProduction;

@end

@protocol ISpeechDelegate
@optional

- (void)ISpeechDelegateStartedSpeaking:(ISpeechSDK *)ispeech;

- (void) ISpeechDelegateFinishedSpeaking:(ISpeechSDK *)ispeech withStatus:(NSError *)status;

- (void) ISpeechDelegateFinishedRecognize:(ISpeechSDK *)ispeech withStatus:(NSError *)status result:(NSString *)text; 

- (void) ISpeechDelegateRecordingUpdate:(ISpeechSDK *)ispeech progress:(UInt32)status;

@end

enum {
	kISpeechRecordingStarted = 1,
	kISpeechRecordingStopped
};
