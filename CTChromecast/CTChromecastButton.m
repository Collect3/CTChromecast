//
//  CTChromecastButton.m
//  Chromecast
//
//  Created by David Fumberger on 13/08/2013.
//  Copyright (c) 2013 Collect3 Pty Ltd. All rights reserved.
//

#import "CTChromecastButton.h"
#import "CTChromecastDeviceListViewController.h"
#import "CTChromecastManager.h"

@interface CTChromecastButton()
@property (nonatomic, strong) UIButton *button;
@end

@implementation CTChromecastButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Style
        [self setImage:[UIImage imageNamed:@"chromecast-on"]  forState:UIControlStateSelected];
        [self setImage:[UIImage imageNamed:@"chromecast-on"]  forState:UIControlStateHighlighted];
        [self setImage:[UIImage imageNamed:@"chromecast-off"] forState:UIControlStateNormal];
        
        // Add actions
        [self addTarget:self action:@selector(actionButtonSelected:) forControlEvents:UIControlEventTouchUpInside];
        
        // Match the behaviour of the airplay button
        self.showsTouchWhenHighlighted = YES;
    }
    return self;
}

- (void)sizeToFit {
    CGRect f = self.frame;
    f.size = CGSizeMake(30, 30);
    self.frame = f;
}

- (void)actionButtonSelected:(UIButton*)sender {
    [[CTChromecastManager sharedInstance] presentDeviceSelectionFromView: sender];
}

@end
