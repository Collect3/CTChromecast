//
//  CTChromecastPlayer.m
//  Chromecast
//
//  Created by David Fumberger on 13/08/2013.
//  Copyright (c) 2013 Collect3 Pty Ltd. All rights reserved.
//

#import "CTChromecastPlayer.h"
#import "CTChromecastManager.h"
#import "CTChromecastVolumeView.h"

NSString *CTChromecastPlayerDurationAvailableNotification        = @"CTChromecastPlayerDurationAvailableNotification";
NSString *CTChromecastPlayerPlaybackStateDidChangeNotification   = @"CTChromecastPlayerPlaybackStateDidChangeNotification";
NSString *CTChromecastPlayerLoadStateDidChangeNotification       = @"CTChromecastPlayerLoadStateDidChangeNotification";
NSString *CTChromecastPlayerVolumeDidChangeNotification          = @"CTChromecastPlayerVolumeDidChangeNotification";
NSString *CTChromecastPlayerPlaybackDidFinishNotification        = @"CTChromecastPlayerPlaybackDidFinishNotification";
@interface CTChromecastPlayerView : UIView
@property (nonatomic, retain) UIImage *logoImage;
@property (nonatomic, retain) UIImageView *tvLogoImageView;
@property (nonatomic, retain) UILabel *titleLabel;
@property (nonatomic, retain) UILabel *descriptionLabel;
@end


@implementation CTChromecastPlayerView

@synthesize titleLabel;
@synthesize descriptionLabel;
@synthesize tvLogoImageView;
@synthesize logoImage;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.tvLogoImageView = [[UIImageView alloc] initWithFrame: CGRectZero];
        self.tvLogoImageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        self.tvLogoImageView.image = [UIImage imageNamed:@"player-tv-connected.png"];
        [self addSubview: self.tvLogoImageView];
        
        self.descriptionLabel = [[UILabel alloc] initWithFrame: CGRectZero];
        self.descriptionLabel.backgroundColor = [UIColor clearColor];
        self.descriptionLabel.textColor = [UIColor lightTextColor];
        self.descriptionLabel.font = [UIFont systemFontOfSize:14];
        self.descriptionLabel.textAlignment = NSTextAlignmentCenter;
        self.descriptionLabel.autoresizingMask = tvLogoImageView.autoresizingMask;
        self.descriptionLabel.numberOfLines = 3;
        [self addSubview: self.descriptionLabel];
        
        self.titleLabel = [[UILabel alloc] initWithFrame: CGRectZero];
        self.titleLabel.backgroundColor = [UIColor clearColor];
        self.titleLabel.textColor = [UIColor lightTextColor];
        self.titleLabel.font = [UIFont systemFontOfSize:20];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.autoresizingMask = tvLogoImageView.autoresizingMask;
        [self addSubview: self.titleLabel];
        
        // Defaults
        titleLabel.text       = NSLocalizedString(@"Chromecast", @"");
    }
    return self;
}

- (void)setLogoImage:(UIImage *)_logoImage {
    tvLogoImageView.image = _logoImage;
}

- (void)layoutSubviews {
    CGSize imageSize       = tvLogoImageView.image.size;
    CGSize titleSize       = [titleLabel.text sizeWithFont: titleLabel.font];
    CGSize descriptionSize = [descriptionLabel.text sizeWithFont:descriptionLabel.font
                                               constrainedToSize:CGSizeMake(imageSize.width, descriptionLabel.font.lineHeight * descriptionLabel.numberOfLines)
                                                   lineBreakMode:NSLineBreakByWordWrapping];

    
    float height = titleSize.height + descriptionSize.height + imageSize.height + 20 + 15;
    float width  = imageSize.width;
    
    float startY = (self.bounds.size.height - height) / 2.0f;
    float startX = (self.bounds.size.width  - width)  / 2.0f;
    
    tvLogoImageView.frame  = CGRectIntegral(CGRectMake(startX, startY, imageSize.width, imageSize.height));
    startY += imageSize.height + 20;
    titleLabel.frame       = CGRectIntegral(CGRectMake(startX, startY, width,           titleSize.height));
    startY += titleSize.height + 15;
    descriptionLabel.frame = CGRectIntegral(CGRectMake(startX, startY, width,          descriptionSize.height));
}

- (void)drawRect:(CGRect)rect {
    // Draw a black to gray gradient in here to avoid gradient banding when scaling
    // and also save bothering with an image dependancy
    CGFloat colors [] = {
        0.27, 0.27, 0.27, 1.0,
        0.0, 0.0, 0.0, 1.0
    };
    
    CGColorSpaceRef baseSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(baseSpace, colors, NULL, 2);
    CGColorSpaceRelease(baseSpace), baseSpace = NULL;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGPoint startPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect));
    CGPoint endPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect));
    
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
    CGGradientRelease(gradient), gradient = NULL;
}
@end

@interface CTChromecastPlayer()
@property (nonatomic, strong) GCKApplicationSession *applicationSession;
@property (nonatomic, strong) GCKMediaProtocolMessageStream *protocolMessageStream;
@property (nonatomic) MPMoviePlaybackState playbackState;
@property (nonatomic) MPMovieLoadState loadState;
@property (nonatomic) NSTimeInterval duration;
@property (nonatomic) CTChromecastPlayerView *playerView;
@property (nonatomic) NSTimeInterval lastKnownPlaybackTime;
@end

@implementation CTChromecastPlayer
- (id)initWithContentURL:(NSURL*)contentURL {
    if (self = [super init]) {
        self.contentURL = contentURL;
        [self connect];
        
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(systemVolumeChangedNotification:) name:CTChromecastVolumeViewChangedNotification object:nil];
    }
    return self;
}

- (void)systemVolumeChangedNotification:(NSNotification*)note {
    [self changeVolume: [note.object floatValue]];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver: self];
    [self unloadMedia];
}

- (void)connect {    
    CTChromecastManager *manager = [CTChromecastManager sharedInstance];
    self.applicationSession = [manager startSessionWithDelegate: self];
}

- (UIView*)view {
    if (_view == nil) {
        self.playerView = [[CTChromecastPlayerView alloc] initWithFrame: CGRectZero];
        self.playerView.descriptionLabel.text = [NSString stringWithFormat:@"The video is playing on %@", [CTChromecastManager sharedInstance].activeDevice.friendlyName];                
        _view = self.playerView;
    }
    return _view;
}

- (void)play {
    [self.protocolMessageStream resumeStream];
}

- (void)prepareToPlay {
    
}

- (void)pause {
    [self.protocolMessageStream stopStream];
}

- (void)stop {
    if (self.playbackState != MPMoviePlaybackStateStopped) {
        [[NSNotificationCenter defaultCenter] postNotificationName:CTChromecastPlayerPlaybackDidFinishNotification object:self];
    }
    [self unloadMedia];
}

- (void)endSeeking {
    // TODO: Implement    
}

- (void)beginSeekingBackward {
    // TODO: Implement        
}

- (void)beginSeekingForward {
    // TODO: Implement    
}

- (float)currentPlaybackRate {
    return 1.0;
}

- (void)setCurrentPlaybackRate:(float)currentPlaybackRate {
    // TODO: Implement
}

- (NSTimeInterval)currentPlaybackTime {
    if (self.protocolMessageStream) {
        return self.protocolMessageStream.streamPosition;
    } else {
        return self.initialPlaybackTime;
    }
}

- (void)setDuration:(NSTimeInterval)duration {
    if (duration != _duration && duration > 0) {
        _duration = duration;
        printf("Duration %f\n", self.protocolMessageStream.streamDuration);
        [[NSNotificationCenter defaultCenter] postNotificationName:CTChromecastPlayerDurationAvailableNotification object:self];
    }
}

- (void)setCurrentPlaybackTime:(NSTimeInterval)currentPlaybackTime {
    [self.protocolMessageStream playStreamFrom:  currentPlaybackTime];
}

- (BOOL)isPreparedToPlay {
    // TODO: Provide a more accurate value
    return YES;
}


- (void)setPlaybackState:(MPMoviePlaybackState)playbackState {
    if (_playbackState != playbackState) {
        _playbackState = playbackState;
        [[NSNotificationCenter defaultCenter] postNotificationName:CTChromecastPlayerPlaybackStateDidChangeNotification object:self];
    }
}

- (void)setLoadState:(MPMovieLoadState)loadState {
    if (_loadState != loadState) {
        _loadState = loadState;
        [[NSNotificationCenter defaultCenter] postNotificationName:CTChromecastPlayerLoadStateDidChangeNotification object:self];
    }
}

- (void)setVolume:(float)volume {
    [self.protocolMessageStream setStreamVolume: volume];
}

- (float)volume {
    return [self.protocolMessageStream volume];
}
#pragma mark -
#pragma mark Media Loading 
#pragma mark -
- (void)unloadMedia {
    [self.protocolMessageStream stopStream];
    [self.applicationSession stopApplicationWhenSessionEnds];
    [self.applicationSession endSession];
    
    [self.protocolMessageStream removeObserver:self forKeyPath:@"playerState"];
    [self.protocolMessageStream removeObserver:self forKeyPath:@"streamDuration"];
    
    self.protocolMessageStream = nil;
    
    self.playbackState = MPMoviePlaybackStateStopped;
}

- (void)loadMedia {
    self.playbackState = MPMoviePlaybackStateStopped;
    self.loadState = MPMovieLoadStateUnknown;
    NSLog(@"CTChromecastPlayer: loadMedia %@", self.contentURL);
    GCKContentMetadata *mData = [[GCKContentMetadata alloc] initWithTitle: [self.contentURL lastPathComponent]
                                     imageURL:nil
                                  contentInfo:nil];
    
    GCKMediaProtocolCommand *cmd = [self.protocolMessageStream loadMediaWithContentID:[self.contentURL absoluteString]
                                                                      contentMetadata:mData];
    cmd.delegate = self;
}

#pragma mark -
#pragma mark Session Delegate
#pragma mark -
// Logs when an application fails to start.
- (void)applicationSessionDidFailToStartWithError:(GCKApplicationSessionError *)errorCode {
    NSLog(@"GCK Session failed to start: %@", errorCode);
}

// Logs when an application fails to end correctly.
- (void)applicationSessionDidEndWithError:(GCKApplicationSessionError *)errorCode {
    NSLog(@"GCK Session ended with error code: %@", errorCode);
    self.applicationSession.delegate = nil;
    self.applicationSession = nil;
}

- (void)applicationSessionDidStart {
    NSLog(@"Application session started");
    self.protocolMessageStream = [[GCKMediaProtocolMessageStream alloc] init];
    [self.protocolMessageStream addObserver:self forKeyPath:@"playerState" options:NSKeyValueObservingOptionNew context:nil];
    [self.protocolMessageStream addObserver:self forKeyPath:@"streamDuration" options:NSKeyValueObservingOptionNew context:nil];
    [self.applicationSession.channel attachMessageStream:self.protocolMessageStream];
    
    NSLog(@"Initiated ramp: %@", self.protocolMessageStream);
    
    [self loadMedia];
    
    if (self.volume > 0.0f) {
        [[NSNotificationCenter defaultCenter] postNotificationName:CTChromecastPlayerVolumeDidChangeNotification
                                                            object: [NSNumber numberWithFloat: self.volume]];        
    }
}

#pragma mark -
#pragma mark KVO
#pragma mark -
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"playerState"]) {
        switch (self.protocolMessageStream.playerState) {
            case kGCKPlayerStateUnknown:
                self.playbackState = MPMoviePlaybackStateInterrupted;
                break;
            case kGCKPlayerStateIdle:
                self.playbackState = MPMoviePlaybackStatePaused;
                break;
            case kGCKPlayerStatePlaying:
                self.playbackState = MPMoviePlaybackStatePlaying;
                break;
            case kGCKPlayerStateStopped:
                self.playbackState = MPMoviePlaybackStateStopped;
                break;
            default:
                break;
        }
    } else if ([keyPath isEqualToString:@"streamDuration"]) {
        self.duration = self.protocolMessageStream.streamDuration;
    } else if ([keyPath isEqualToString:@"streamVolume"]) {
        NSLog(@"volume changed");
    }
}

#pragma mark -
#pragma mark - MediaProtocolCommandDelegate
#pragma mark -
// Begins playback upon successfully loading a piece of media.
- (void) mediaProtocolCommandDidComplete:(GCKMediaProtocolCommand *)command {
    self.playbackState = MPMoviePlaybackStatePlaying;
    self.loadState     = MPMovieLoadStatePlaythroughOK;
    
    NSLog(@"mediaProtocolCommandDidComplete");
    //[self.volumeSlider setValue:[self.mMPMS volume] animated:YES];
    //[self.mMPMS setStreamVolume:0.5];
    NSLog(@"Starting cast playback");
    NSLog(@"playPosition: %f", self.initialPlaybackTime);
    [self.protocolMessageStream playStreamFrom:self.initialPlaybackTime];
    [[NSNotificationCenter defaultCenter] postNotificationName:CTChromecastPlayerVolumeDidChangeNotification
                                                        object: [NSNumber numberWithFloat: self.volume]];
    
    
}

// Logs a cancelled load command.
- (void)mediaProtocolCommandWasCancelled:(GCKMediaProtocolCommand *)command {
    NSLog(@"mediaProtocolCommandWasCancelled");
}

#pragma mark -
#pragma mark Volume
#pragma mark -
- (void)changeVolume:(float)volume {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(_changeVolume:) withObject: [NSNumber numberWithFloat: volume] afterDelay:0.25];
}
- (void)_changeVolume:(NSNumber*)volume {
    printf("Chagngin %f\n", [volume floatValue]);
    self.volume = [volume floatValue];
}
@end
