//
//  CTChromecastDeviceListViewController.h
//  Chromecast
//
//  Created by David Fumberger on 12/08/2013.
//  Copyright (c) 2013 Collect3 Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CTChromecastManager.h"
#include <GCKFramework/GCKFramework.h>

extern NSString *CTChromecastDeviceListShow;
extern NSString *CTChromecastDeviceListHide;

typedef void (^CTChromecastDeviceListSelection)(GCKDevice *device);

@interface CTChromecastDeviceListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, UIPopoverControllerDelegate>
@property (nonatomic, strong) CTChromecastDeviceListSelection selectionHandler;
- (void)showAsActionSheet;
- (void)showAsPopoverFromView:(UIView*)view;
- (void)showAsModal;
@end
