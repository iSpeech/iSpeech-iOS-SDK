//
//  ISpeechSDK+Compatibility.m
//  iSpeechSDK
//
//  Copyright (c) 2012 iSpeech, Inc. All rights reserved.
//

#import "ISpeechSDK+Compatibility.h"

// define some LLVM3 macros if the code is compiled with a different compiler (ie LLVMGCC42)
#ifndef __has_feature
#define __has_feature(x) 0
#endif
#ifndef __has_extension
#define __has_extension __has_feature // Compatibility with pre-3.0 compilers.
#endif

#ifndef IS_ARC_ENABLED
#if __has_feature(objc_arc) && __clang_major__ >= 3
	#define IS_ARC_ENABLED 1
#endif // __has_feature(objc_arc)
#endif // IS_ARC_ENABLED

#ifndef IS_RELEASE_SAFELY

#if defined(IS_ARC_ENABLED) && IS_ARC_ENABLED
	#define IS_RELEASE_SAFELY(x) x = nil;
#else
	#define IS_RELEASE_SAFELY(x) [x release]; x = nil;
#endif // __has_feature(objc_arc)

#endif // IS_RELEASE_SAFELY

#ifndef IS_RETAIN_AUTORELEASE

#if defined(IS_ARC_ENABLED) && IS_ARC_ENABLED
	#define IS_RETAIN_AUTORELEASE(x) x
#else
	#define IS_RETAIN_AUTORELEASE(x) [[x retain] autorelease]
#endif // IS_RETAIN_AUTORELEASE

#endif // IS_RELEASE_SAFELY

@implementation ISpeechSDK

- (void)p_applyListsToRecognition {
	if(aliasList != nil) {
		for(NSString *key in aliasList) {
			if(![key isKindOfClass:[NSString class]]) {
				continue;
			}
			
			id obj = [aliasList objectForKey:key];
			
			[activeRecognition addAlias:key forItems:obj];
		}
	}
	
	if(commandList != nil) {
		for(int i = 0, len = [commandList count]; i < len; i++) {
			id obj = [commandList objectAtIndex:i];
			
			if([obj isKindOfClass:[NSString class]]) {
				[activeRecognition addCommand:obj];
			} else if([obj isKindOfClass:[NSArray class]]) {
				[activeRecognition addCommands:obj];
			}
		}
	}
}

+ (ISpeechSDK *) ISpeech:(NSString *)apiKey provider:(NSString *)provName application:(NSString *)appName useProduction:(BOOL)useProduction {
	static ISpeechSDK *sdk = nil;
	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		NSLog(@"WARNING: The ISpeechSDK class is only provided for compatibility purposes while you migrate to the new version of the SDK. It will *NOT* be maintained past this initial release, and if you are using it while asking for support, you will be prompted to upgrade to the new SDK before we provide support.");
		
#ifdef IS_ARC_ENABLED
		sdk = [[ISpeechSDK alloc] init];
#else
		sdk = [[[ISpeechSDK alloc] init] retain]; // The retain is to maintain implementation details with old SDK. (Old one over retained. :/)
#endif
		
		[[iSpeechSDK sharedSDK] setAPIKey:apiKey];
		[[iSpeechSDK sharedSDK] setUsesDevServer:!useProduction];
	});
	
	return sdk;
}

- (id) ISpeechSetSpeakingDone:(id)delegate {
	id previousDelegate = speakingDelegate;
	
	if(delegate && (![delegate respondsToSelector:@selector(ISpeechDelegateFinishedSpeaking:withStatus:)] || ![delegate respondsToSelector:@selector(ISpeechDelegateStartedSpeaking:)])) {
		delegate = nil;
	}
	
	speakingDelegate = delegate;
	
	return previousDelegate;
}

- (void) ISpeechSetVoice:(NSString *)voice {
	[[[iSpeechSDK sharedSDK] configuration] setVoice:voice];
}

- (NSString *)ISpeechVoice {
	return [[[iSpeechSDK sharedSDK] configuration] voice];
}

- (void) ISpeechSetSpeed:(NSInteger)speed {
	[[[iSpeechSDK sharedSDK] configuration] setSpeed:speed];
}

- (NSInteger) ISpeechSpeed {
	return [[[iSpeechSDK sharedSDK] configuration] speed];
}

- (void) ISpeechSetModel:(NSString *)model {
	[[[iSpeechSDK sharedSDK] configuration] setModel:model];
}

- (NSString *)ISpeechModel {
	return [[[iSpeechSDK sharedSDK] configuration] model];
}

- (void)ISSpeechSetExtraServerParameters:(NSString *)params {
	[[iSpeechSDK sharedSDK] setExtraServerParams:params];
}

- (void) ISpeechSetLocale:(NSString *)locale {
	[[[iSpeechSDK sharedSDK] configuration] setLocale:locale];
}

- (NSString *) ISpeechLocale {
	return [[[iSpeechSDK sharedSDK] configuration] locale];
}

- (BOOL) ISpeechSpeak:(NSString *)text {
	return [self ISpeechSpeak:text error:nil];
}

- (BOOL) ISpeechSpeak:(NSString *)text error:(NSError **)errPtr {
	if([[iSpeechSDK sharedSDK] isBusy]) {
		return NO;
	}
	
	activeSynthesis = [[ISSpeechSynthesis alloc] initWithText:text];
	[activeSynthesis setDelegate:self];
	return [activeSynthesis speak:errPtr];
}

- (void) ISpeechStopSpeaking {
	[activeSynthesis cancel];
	
	IS_RELEASE_SAFELY(activeSynthesis);
}

- (BOOL) ISpeechIsSpeaking {
	return (activeSynthesis != nil);
}

- (BOOL) ISpeechCancelListen {
	[activeRecognition cancel];
	
	IS_RELEASE_SAFELY(activeRecognition);
	
	return YES;
}

- (NSString *) ISpeechGetRecognizeResult {
	return IS_RETAIN_AUTORELEASE(recognizeResult);
}

- (float) ISpeechGetRecognizeConfidence {
	return recognizeConfidence;
}

- (id) ISpeechSetRecognizeDone:(id)delegate {
	id previousDelegate = speakingDelegate;
	
	if(delegate && ![delegate respondsToSelector:@selector(ISpeechDelegateFinishedRecognize:withStatus:result:)]) {
		delegate = nil;
	}
	
	hasRecordingUpdate = (delegate && [delegate respondsToSelector:@selector(ISpeechDelegateRecordingUpdate:progress:)]);
	
	recognizeDelegate = delegate;
	
	return previousDelegate;
}

- (void) ISpeechSilenceDetectAfter:(NSTimeInterval)seconds forDuration:(NSTimeInterval)duration {
	if(seconds == 0 || duration == 0) {
		enableSilenceDetection = NO;
	} else {
		enableSilenceDetection = YES;
	}
}

- (BOOL) ISpeechStartListenWithError:(NSError **)errPtr {
	if([[iSpeechSDK sharedSDK] isBusy]) {
		return NO;
	}
	
	activeRecognition = [[ISSpeechRecognition alloc] init];
	[activeRecognition setSilenceDetectionEnabled:enableSilenceDetection];
	[activeRecognition setDelegate:self];
	
	enableSilenceDetection = NO;
	
	[self p_applyListsToRecognition];
	
	return [activeRecognition listen:errPtr];
}

- (BOOL) ISpeechStartListen {
	return [self ISpeechStartListenWithError:nil];
}

- (BOOL) ISpeechStopListenStartRecognize {
	if(activeRecognition == nil) {
		return NO;
	}
	
	[activeRecognition finishListenAndStartRecognize];
	
	return YES;
}

- (BOOL) ISpeechListenThenRecognizeWithTimeout:(NSTimeInterval)seconds {
	return [self ISpeechListenThenRecognizeWithTimeout:seconds error:nil];
}

- (BOOL) ISpeechListenThenRecognizeWithTimeout:(NSTimeInterval)seconds error:(NSError **)errPtr {
	if([[iSpeechSDK sharedSDK] isBusy]) {
		return NO;
	}
	
	activeRecognition = [[ISSpeechRecognition alloc] init];
	[activeRecognition setSilenceDetectionEnabled:enableSilenceDetection];
	[activeRecognition setDelegate:self];
	
	enableSilenceDetection = NO;
	
	[self p_applyListsToRecognition];
	
	return [activeRecognition listenAndRecognizeWithTimeout:seconds error:errPtr];
}

- (void) ISpeechAddRecognitionList:(NSArray *)strings {
	if(!commandList) {
		commandList = [[NSMutableArray alloc] init];
	}
	
	if([strings count] == 1) {
		[commandList addObject:[strings lastObject]];
	} else {
		[commandList addObject:strings];
	}
}

- (void) ISpeechAddRecognitionAlias:(NSString *)aliasName forList:(NSArray *)strings {
	if(!aliasList) {
		aliasList = [[NSMutableDictionary alloc] init];
	}
	
	[aliasList setObject:strings forKey:aliasName];
}

- (void) ISpeechClearRecognitionList {
	[commandList removeAllObjects];
	[aliasList removeAllObjects];
}

- (BOOL) ISpeechListenThenRecognize:(NSString *)stringOfWords separatedBy:(NSString *)wordSeparator withTimeout:(NSTimeInterval)seconds {
	return [self ISpeechListenThenRecognize:stringOfWords separatedBy:wordSeparator withTimeout:seconds error:nil];
}

- (BOOL) ISpeechListenThenRecognize:(NSString *)stringOfWords separatedBy:(NSString *)wordSeparator withTimeout:(NSTimeInterval)seconds error:(NSError **)errPtr {
	if(activeRecognition != nil) {
		return NO;
	}
	
	activeRecognition = [[ISSpeechRecognition alloc] init];
	[activeRecognition setSilenceDetectionEnabled:enableSilenceDetection];
	[activeRecognition setDelegate:self];
	
	enableSilenceDetection = NO;
	
	NSArray *commands = [stringOfWords componentsSeparatedByString:wordSeparator];
	
	[self ISpeechAddRecognitionList:commands];
	
	[self p_applyListsToRecognition];
	
	return [activeRecognition listenAndRecognizeWithTimeout:seconds error:errPtr];
}

- (BOOL) ISpeechIsRecognizing {
	return (activeRecognition != nil);
}

- (id)init {
	if((self = [super init])) {
		
	}
	
	return self;
}

#pragma mark - ISSpeechSynthesis Delegate

- (void)synthesisDidStartSpeaking:(ISSpeechSynthesis *)speechSynthesis {
	[speakingDelegate ISpeechDelegateStartedSpeaking:self];
}

- (void)synthesisDidFinishSpeaking:(ISSpeechSynthesis *)speechSynthesis userCancelled:(BOOL)userCancelled {
	NSError *error = nil;
	
	if(userCancelled) {
		error = [NSError errorWithDomain:iSpeechErrorDomain code:kISpeechErrorCodeUserCancelled userInfo:nil];
	}
	
	[self synthesis:speechSynthesis didFailWithError:error];
	
	IS_RELEASE_SAFELY(activeSynthesis);
}

- (void)synthesis:(ISSpeechSynthesis *)speechSynthesis didFailWithError:(NSError *)error {
	[speakingDelegate ISpeechDelegateFinishedSpeaking:self withStatus:error];
	
	IS_RELEASE_SAFELY(activeSynthesis);
}

#pragma mark - ISSpeechRecognition Delegate

- (void)recognition:(ISSpeechRecognition *)speechRecognition didGetRecognitionResult:(ISSpeechRecognitionResult *)result {
	[recognizeDelegate ISpeechDelegateFinishedRecognize:self withStatus:nil result:result.text];
	
#ifdef IS_ARC_ENABLED
	recognizeResult = result.text;
#else
	[recognizeResult release];
	recognizeResult = [result.text copy];
#endif
	
	recognizeConfidence = [result confidence];
	
	IS_RELEASE_SAFELY(activeRecognition);
}

- (void)recognition:(ISSpeechRecognition *)speechRecognition didFailWithError:(NSError *)error {
	[recognizeDelegate ISpeechDelegateFinishedRecognize:self withStatus:error result:nil];
	
	IS_RELEASE_SAFELY(activeRecognition);
}

- (void)recognitionCancelledByUser:(ISSpeechRecognition *)speechRecognition {
	NSError *error = [NSError errorWithDomain:iSpeechErrorDomain code:kISpeechErrorCodeUserCancelled userInfo:nil];
	
	[self recognition:speechRecognition didFailWithError:error];
	
	IS_RELEASE_SAFELY(activeRecognition);
}

- (void)recognitionDidBeginRecording:(ISSpeechRecognition *)speechRecognition {
	if(hasRecordingUpdate) {
		[recognizeDelegate ISpeechDelegateRecordingUpdate:self progress:kISpeechRecordingStarted];
	}
}

- (void)recognitionDidFinishRecording:(ISSpeechRecognition *)speechRecognition {
	if(hasRecordingUpdate) {
		[recognizeDelegate ISpeechDelegateRecordingUpdate:self progress:kISpeechRecordingStopped];
	}
}

@end
