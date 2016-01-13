//
//  ISViseme.h
//  iSpeechSDK
//
//  Created by Grant Butler on 8/28/12.
//  Copyright (c) 2012 iSpeech, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * Represents a single viseme in a array of visemes.
 */
@interface ISViseme : NSObject

/**
 * The time, in seconds, that this viseme should appear at, in relation to an audio file.
 */
@property (nonatomic, assign) NSTimeInterval start;

/**
 * The time, in seconds, that this viseme should disappear at, in relation to an audio file.
 */
@property (nonatomic, assign) NSTimeInterval end;

/**
 * The time, in seconds, for how long this viseme shold appear onscreen.
 */ 
@property (nonatomic, assign) NSTimeInterval length;

/**
 * Which mouth this viseme uses.
 *
 * A number between 0 and 21. See the [Conversive Character Studio Visemes](http://www.verbots.com/wiki/Tools:Conversive_Character_Studio_Sample_Visemes) for details on what each value means.
 *
 * @note The Conversive Character Studio Visemes indicies are 1-based, where iSpeech's visemes are 0-based. Just subtract one from the Conversive Character Studio Visemes to get the equivalent iSpeech viseme. 
 */
@property (nonatomic, assign) NSInteger mouth;

@end
