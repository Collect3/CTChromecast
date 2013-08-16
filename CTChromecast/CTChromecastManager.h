//
//  CTChromecastManager.h
//  Chromecast
//
//  Created by David Fumberger on 12/08/2013.
//  Copyright (c) 2013 Collect3 Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#include <GCKFramework/GCKFramework.h>

typedef void (^CTChromecastDeviceIconFetchCompletion)(NSArray *icons);

// Events
extern NSString *CTChromecastManagerDidConnectToDeviceNotification;
extern NSString *CTChromecastManagerDidDisconnectFromDeviceNotification;
extern NSString *CTChromecastManagerDeviceListUpdatedNotification;

@interface CTChromecastLocalDevice : GCKDevice
@end

@interface CTChromecastManager : NSObject <GCKDeviceManagerListener, UIPopoverControllerDelegate>

/** Host for the app */
@property (nonatomic, copy) NSString *host;
@property (nonatomic, copy) NSString *applicationID;

/** List of found devices */
@property (nonatomic, readonly) NSArray *devices;

@property (nonatomic, readonly) NSArray *devicesWithLocal;

/** Current device we're broadcasting to */
@property (nonatomic, readonly) GCKDevice *activeDevice;

@property (nonatomic, assign) BOOL isLocalPlayback;

@property (nonatomic, readonly) CTChromecastLocalDevice *localDevice;

/** Whether a scan is currently in progress. */
@property(nonatomic, readonly) BOOL scanningForDevices;

/** Period to wake up and scan for new devices */
@property(nonatomic, assign) CFTimeInterval scanInterval;

+ (CTChromecastManager*)sharedInstance;

/** Starts listening for devices */
- (void)start;

/** Stops listening devices */
- (void)stop;

/** Connects to the selected device for playback */
- (void)connectToDevice:(GCKDevice*)device;

/** Player(s) call this to start a session
    They then handle the rest of the communication
 */
- (GCKApplicationSession*)startSessionWithDelegate:(id)delegate;

/** Returns list of icons for device 
    May need to fetch remotely. Completion handler will be called on the main thread.
 */
- (void)iconsForDevice:(GCKDevice*)device completionHandler:(CTChromecastDeviceIconFetchCompletion)completion;

/**
    Call to show the device selection list
    Is called by CTChromecastButton and can be used for further customisation of the device list.
*/
- (void)presentDeviceSelectionFromView:(UIView*)view;
@end
