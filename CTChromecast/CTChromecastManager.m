//
//  CTChromecastManager.m
//  Chromecast
//
//  Created by David Fumberger on 12/08/2013.
//  Copyright (c) 2013 Collect3 Pty Ltd. All rights reserved.
//

#import "CTChromecastManager.h"
#import "CTChromecastDeviceListViewController.h"

static NSString *kContextUserAgent = @"com.collect3.mediaplayer";

NSString *CTChromecastManagerDidConnectToDeviceNotification      = @"kCTChromecastManagerDidConnectToDeviceNotification";
NSString *CTChromecastManagerDidDisconnectFromDeviceNotification = @"kCTChromecastManagerDidDisconnectFromDeviceNotification";
NSString *CTChromecastManagerDeviceListUpdatedNotification       = @"kCTChromecastManagerDeviceListUpdatedNotification";
@implementation CTChromecastLocalDevice
- (NSArray*)icons {
    NSString *iconName = @"chromecast-device-iphone-5";
    NSString *modelName = [[UIDevice currentDevice] model];
    if ([modelName hasPrefix:@"iPad"]) {
        iconName = @"chromecast-device-ipad";
    } else if ([modelName hasPrefix:@"iPad Mini"]) {
        iconName = @"chromecast-device-ipad-mini";
    }
    
    NSString *path = [[NSBundle mainBundle] pathForResource:iconName ofType:@"png"];
        
    GCKDeviceIcon *icon = [[GCKDeviceIcon alloc] initWithWidth:10 height:10 depth:1 url: [NSURL fileURLWithPath:path] ];
    return @[ icon ];
}

@end

@interface CTChromecastManager()
@property (nonatomic, strong) GCKDeviceManager *deviceManager;
@property (nonatomic, strong) CTChromecastLocalDevice *localDevice;
@property (nonatomic, strong) GCKDevice *activeDevice;
@property (nonatomic, strong) NSTimer *scanTimer;
@property (nonatomic, assign) BOOL scanningForDevices;
@property (nonatomic, strong) NSMutableArray *devices;
@property (nonatomic, strong) NSCache *iconCache;
@property (nonatomic, strong) CTChromecastDeviceListViewController *deviceSelection;
@end

@implementation CTChromecastManager


+ (CTChromecastManager*)sharedInstance {
    static CTChromecastManager *sharedInstance = nil;
    static dispatch_once_t onceToken;    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[CTChromecastManager alloc] init];
    });
    return sharedInstance;
}

- (id)init {
    if (self = [super init]) {
        GCKContext *context = [[GCKContext alloc] initWithUserAgent:kContextUserAgent];
        self.deviceManager = [[GCKDeviceManager alloc] initWithContext:context];
        [self.deviceManager addListener: self];

        self.localDevice = [[CTChromecastLocalDevice alloc] initWithIPAddress:@"127.0.0.1"];
        self.localDevice.friendlyName = [[UIDevice currentDevice] name];

        self.activeDevice = nil;
        
        self.scanInterval = 30.0f;            
    }
    return self;
}

- (void)connectToDevice:(GCKDevice*)device {
    // Already local playback
    if (device == self.localDevice && self.activeDevice == nil) {
        return;
    }
    
    // Already using this device
    if (device == self.activeDevice) {
        return;
    }
    
    if (device == self.localDevice) {
        self.activeDevice = nil;
        [[NSNotificationCenter defaultCenter] postNotificationName:CTChromecastManagerDidDisconnectFromDeviceNotification object:self];
    } else {
        self.activeDevice = device;
        [[NSNotificationCenter defaultCenter] postNotificationName:CTChromecastManagerDidConnectToDeviceNotification object:self];
    }
}

- (BOOL)isLocalPlayback {
    return (self.activeDevice == nil) ? YES : NO;
}

- (GCKApplicationSession*)startSessionWithDelegate:(id)delegate {
    GCKMimeData *mimeData = [[GCKMimeData alloc] initWithTextData:self.host
                                                             type:kGCKMimeText];
    GCKApplicationSession *applicationSession = [[GCKApplicationSession alloc] initWithContext:self.deviceManager.context
                                                                    device:self.activeDevice];
    applicationSession.delegate = delegate;
    [applicationSession startSessionWithApplication: self.applicationID
                                            argument:mimeData];
    return applicationSession;
}


#pragma mark -
#pragma mark Application Delegate
#pragma mark -

#pragma mark -
#pragma mark Scanning
#pragma mark -
- (void)setScanInterval:(CFTimeInterval)scanInterval {
    _scanInterval = scanInterval;
    [self stop];
    [self start];
}

- (void)start {
    if (self.scanTimer) {
        return;
    }
    self.scanTimer = [NSTimer scheduledTimerWithTimeInterval:self.scanInterval
                                     target:self
                                   selector:@selector(performScan)
                                   userInfo:nil
                                    repeats:YES];
    [self performScan];
}

- (void)stop {
    [self.scanTimer invalidate];
    self.scanTimer = nil;
}

- (void)performScan {
    NSLog(@"performScan");
    self.scanningForDevices = YES;
    [self.deviceManager startScan];
    [self performSelector:@selector(finishScan) withObject:nil afterDelay:4.0];
}

- (void)finishScan {
    NSLog(@"finishScann");    
    [self.deviceManager stopScan];
    self.scanningForDevices = NO;
}

#pragma mark -
#pragma mark Device Management
#pragma mark -
- (NSArray*)devicesWithLocal {
    return [@[ self.localDevice ] arrayByAddingObjectsFromArray: self.devices];
}

#pragma mark -
#pragma mark Listener Methods
#pragma mark -
- (void)deviceDidComeOnline:(GCKDevice *)device {
    if (self.devices == nil) {
        self.devices = [NSMutableArray array];
    }
    if (![self.devices containsObject: device]) {
        NSLog(@"New device found %@", device);    
        [(NSMutableArray*)self.devices addObject: device];
        [[NSNotificationCenter defaultCenter] postNotificationName:CTChromecastManagerDeviceListUpdatedNotification object:self];
    }
}

/**
 * Called when a device has gone offline.
 *
 * @param device The device.
 */
- (void)deviceDidGoOffline:(GCKDevice *)device {
    NSLog(@"Device went offline %@", device);        
    [(NSMutableArray*)self.devices removeObject: device];
    if ([self.devices count] == 0) {
        self.devices = nil;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:CTChromecastManagerDeviceListUpdatedNotification object:self];
}

#pragma mark -
#pragma mark Device Selection UI
#pragma mark -
- (void)presentDeviceSelectionFromView:(UIView*)view {
    self.deviceSelection = [[CTChromecastDeviceListViewController alloc] init];

    //__weak CTChromecastManager* s = self;
    __unsafe_unretained CTChromecastManager *s = self;
    self.deviceSelection.selectionHandler = ^(GCKDevice *device) {
        if (device) {
            [s connectToDevice: device];
            s.deviceSelection = nil;
        }
    };
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [self.deviceSelection showAsPopoverFromView: view];
    } else {
        if (self.devices.count > 3) {
            [self.deviceSelection showAsModal];
        } else {
            [self.deviceSelection showAsActionSheet];
        }
    }
}
#pragma mark -
#pragma mark Icon 
#pragma mark -
- (NSArray*)cachedIconsForDevice:(GCKDevice*)device {
    NSArray *a = [self.iconCache objectForKey: device.deviceID];
    return a;
}

- (void)iconsForDevice:(GCKDevice*)device completionHandler:(CTChromecastDeviceIconFetchCompletion)completion {
    NSArray *icons = [self cachedIconsForDevice: device];
    if (icons) {
        completion(icons);
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(void) {
        NSMutableArray *images = [NSMutableArray array];
        for (GCKDeviceIcon *icon in device.icons) {
            NSData *d = [NSData dataWithContentsOfURL: icon.url];
            UIImage *i = [UIImage imageWithData:d];
            [images addObject: i];
        }
        if (self.iconCache == nil) {
            self.iconCache = [[NSCache alloc] init];
        }
        [self.iconCache setObject:images forKey: device.deviceID];
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            completion(images);
        });

    });
}

@end
