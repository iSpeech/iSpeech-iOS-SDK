//
//  ISViewController.h
//  iSpeechSample
//
//  Created by Grant Butler on 1/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ISpeechSDK.h"

@interface ISViewController : UIViewController <ISSpeechRecognitionDelegate>

@property (nonatomic, strong) IBOutlet UILabel *label;
@property (unsafe_unretained, nonatomic) IBOutlet UITextView *sayTextView;
@property (nonatomic, strong) ISSpeechRecognition *recognition;

@end
