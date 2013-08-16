//
//  CTChromecastViewController.m
//  Chromecast
//
//  Created by David Fumberger on 12/08/2013.
//  Copyright (c) 2013 Collect3 Pty Ltd. All rights reserved.
//

#import "CTChromecastViewController.h"

@interface CTChromecastViewController ()

@end

@implementation CTChromecastViewController

- (void)viewDidLoad
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(debugNotifications:) name:nil object:nil];
    [super viewDidLoad];
    [self showPlayer];    
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)debugNotifications:(NSNotification*)note {
    if ([note.name hasPrefix:@"MPMovie"] ||
        [note.name hasPrefix:@"CTChromecast"]) {
        NSLog(@"%@", note.name);
    }
}

- (void)viewDidAppear:(BOOL)animated {

}

- (void)showPlayer {
    NSLog(@"Loading");
    
    self.player = [[CTChromecastMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:@"http://commondatastorage.googleapis.com/gtv-videos-bucket/big_buck_bunny_1080p.mp4"]];
    self.player.controlStyle = MPMovieControlStyleDefault;
    self.player.view.frame = self.view.bounds;
    self.player.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    [self.view addSubview: self.player.view];
    
    [self.player prepareToPlay];
    [self.player play];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
