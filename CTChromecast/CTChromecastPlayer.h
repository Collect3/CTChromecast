//
//  CTChromecastPlayer.h
//  Chromecast
//
//  Created by David Fumberger on 13/08/2013.
//  Copyright (c) 2013 Collect3 Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>
#include <GCKFramework/GCKFramework.h>

extern NSString *CTChromecastPlayerDurationAvailableNotification;
extern NSString *CTChromecastPlayerPlaybackStateDidChangeNotification;
extern NSString *CTChromecastPlayerLoadStateDidChangeNotification;
extern NSString *CTChromecastPlayerVolumeDidChangeNotification;
extern NSString *CTChromecastPlayerPlaybackDidFinishNotification;

@interface CTChromecastPlayer : NSObject <MPMediaPlayback, GCKMediaProtocolCommandDelegate>
@property (nonatomic, strong) NSURL *contentURL;
@property (nonatomic, strong) UIView *view;

// MPMoviePlayer mirror props
@property (nonatomic, readonly) MPMoviePlaybackState playbackState;
@property (nonatomic, readonly) MPMovieLoadState loadState;
@property (nonatomic, readonly) NSTimeInterval duration;
@property (nonatomic) NSTimeInterval initialPlaybackTime;

// Chromecast specific
@property (nonatomic) float volume;

- (id)initWithContentURL:(NSURL*)contentURL;
@end
