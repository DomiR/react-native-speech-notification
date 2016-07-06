//
//  SpeechNotificationDelegate.m
//  SpeechNotificationDelegate
//
//  Created by Francis Knarfy Elopre on 05/07/2016.
//  Copyright © 2016 Francis Knarfy Elopre. All rights reserved.
//

#import "SpeechNotificationDelegate.h"

@implementation SpeechNotificationDelegate

-(instancetype)init
{
  self = [super init];
  if (self) {
    synthesizer = [AVSpeechSynthesizer new];
    synthesizer.delegate = self;
  }

  return self;
}

- (void)speechSynthesizer:(AVSpeechSynthesizer*)synthesizer didFinishSpeechUtterance:(AVSpeechUtterance*)utterance
{
  // TODO: Return result
  //  CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
  //  if (lastCallbackId) {
  //    [self.commandDelegate sendPluginResult:result callbackId:lastCallbackId];
  //    lastCallbackId = nil;
  //  } else {
  //    [self.commandDelegate sendPluginResult:result callbackId:callbackId];
  //    callbackId = nil;
  //  }

  [[AVAudioSession sharedInstance] setActive:NO withOptions:0 error:nil];
  [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback
  withOptions: 0 error: nil];
  [[AVAudioSession sharedInstance] setActive:YES withOptions: 0 error:nil];
}

- (void)speak:(NSDictionary*)params
{
  if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]){
    [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil]];
  }

  [[AVAudioSession sharedInstance] setActive:NO withOptions:0 error:nil];
  [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback
  withOptions:AVAudioSessionCategoryOptionInterruptSpokenAudioAndMixWithOthers error:nil];

  [synthesizer stopSpeakingAtBoundary:AVSpeechBoundaryWord];

  NSString *message = [params objectForKey:@"message"];
  NSString *language = [params objectForKey:@"language"];

  if (!language || (id)language == [NSNull null]) {
    language = @"en-US";
  }

  UIApplicationState state = [[UIApplication sharedApplication] applicationState];

  UILocalNotification *notification = [[UILocalNotification alloc]init];
  [notification setAlertBody:message];

  AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:message];
  [utterance setVoice:[AVSpeechSynthesisVoice voiceWithLanguage:language]];

  if (state == UIApplicationStateActive) {
    [synthesizer speakUtterance:utterance];
  }
  else{
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    [[UIApplication sharedApplication] setScheduledLocalNotifications:[NSArray arrayWithObject:notification]];
    [synthesizer speakUtterance:utterance];
  }
}

@end