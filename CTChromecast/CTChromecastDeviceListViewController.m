//
//  CTChromecastDeviceListViewController.m
//  Chromecast
//
//  Created by David Fumberger on 12/08/2013.
//  Copyright (c) 2013 Collect3 Pty Ltd. All rights reserved.
//

#import "CTChromecastDeviceListViewController.h"
#include <GCKFramework/GCKFramework.h>

NSString *CTChromecastDeviceListShow = @"CTChromecastDeviceListShow";
NSString *CTChromecastDeviceListHide = @"CTChromecastDeviceListHide";


@interface CTChromecastDeviceListTitleView : UIView
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UIActivityIndicatorView *progressView;
@end

@implementation CTChromecastDeviceListTitleView

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame: frame]) {
        self.label = [[UILabel alloc] initWithFrame: CGRectZero];
        self.label.backgroundColor = [UIColor clearColor];
        self.label.textColor = [UIColor whiteColor];
        self.label.font = [UIFont boldSystemFontOfSize:18];
        [self addSubview: self.label];
        
        self.progressView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [self addSubview: self.progressView];
    }
    return self;
}

- (void)layoutSubviews {
    [self.label sizeToFit];
    self.label.frame = CGRectMake( (self.bounds.size.width - self.label.frame.size.width) / 2.0f,
                                   (self.bounds.size.height - self.label.frame.size.height) / 2.0f,
                                  self.label.frame.size.width, self.label.frame.size.height);
    
    [self.progressView layoutSubviews];
    self.progressView.frame = CGRectMake(self.label.frame.origin.x - self.progressView.frame.size.width - 5,
                                         (self.bounds.size.height - self.progressView.frame.size.height) / 2.0,
                                         self.progressView.frame.size.width, self.progressView.frame.size.height);
    [super layoutSubviews];
}

@end

@interface CTChromecastDeviceListViewController ()
@property (nonatomic, strong) NSArray *devices;
@property (nonatomic, strong) UIActionSheet *sheet;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) CTChromecastManager *manager;
@property (nonatomic, strong) UIPopoverController *currentPopover;
@property (nonatomic, strong) UINavigationController *currentModal;
@end

@implementation CTChromecastDeviceListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)init {
    if (self = [super init]) {
        // Asign manager
        self.manager = [CTChromecastManager sharedInstance];
        
        // Grab devices
        self.devices = self.manager.devicesWithLocal;
        
        [self.manager addObserver:self forKeyPath:@"scanningForDevices" options:NSKeyValueObservingOptionNew context:nil];
        [self.manager addObserver:self forKeyPath:@"devices" options:NSKeyValueObservingOptionNew context:nil];        
    }
    return self;
}

- (CTChromecastDeviceListTitleView*)createTitleView {
    CTChromecastDeviceListTitleView *titleView = [[CTChromecastDeviceListTitleView alloc] initWithFrame: CGRectZero];
    titleView.label.text = self.title;
    return titleView;
}

- (void)viewDidLoad {
    self.title = @"Select Device";
        
    // Setup table view
    self.tableView = [UITableView new];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview: self.tableView];
    
    [self.tableView reloadData];

    // Update header
    self.navigationItem.titleView = [self createTitleView];
    [self updateHeader];
    
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] postNotificationName:CTChromecastDeviceListShow object:self];
    [super viewWillAppear: animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] postNotificationName:CTChromecastDeviceListHide object:self];
    [super viewWillDisappear: animated];
}

- (void)dealloc {
    [self.manager removeObserver:self forKeyPath:@"scanningForDevices"];
    [self.manager removeObserver:self forKeyPath:@"devices"];
    self.selectionHandler = nil;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if ([keyPath isEqualToString:@"scanningForDevices"]) {
        [self updateHeader];
    } else if ([keyPath isEqualToString:@"devices"]) {
        [self.tableView reloadData];
    }
}

- (void)updateHeader {
    CTChromecastDeviceListTitleView *header = (CTChromecastDeviceListTitleView*)self.navigationItem.titleView;
    if (self.manager.scanningForDevices) {
        [header.progressView startAnimating];
    } else {
        [header.progressView stopAnimating];
    }
}

- (void)viewWillLayoutSubviews {
    self.tableView.frame = self.view.bounds;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.devices count];
}

- (CGSize)contentSizeForViewInPopover {
    return CGSizeMake(300, 300);
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *reuseIdentifier = @"CTChromecastDeviceCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: reuseIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    }
    
    // Get device
    GCKDevice *device = [self.devices objectAtIndex: indexPath.row];
    
    // Populate cell
    cell.textLabel.text = device.friendlyName;
    

    [self.manager iconsForDevice:device completionHandler:^(NSArray *icons) {
        if ([icons count] > 0) {
            cell.imageView.image = [icons objectAtIndex:0];
            [cell setNeedsLayout];
        }
    }];
    
    // Flag if selected
    if (self.manager.activeDevice == nil && device == self.manager.localDevice) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else if (self.manager.activeDevice == device) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    GCKDevice *device = [self.devices objectAtIndex: indexPath.row];
    self.selectionHandler(device);
    [self.tableView reloadData];
    if (self.currentModal) {
        [self dismissModal];
    }
    if (self.currentPopover) {
        [self dismissPopover];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark Action Sheet style
#pragma mark -
- (UIView*)rootView {
    UIWindow *w = [[UIApplication sharedApplication].windows objectAtIndex:0];
    return w.rootViewController.view;
}
- (void)showAsActionSheet {
    [self showAsActionSheetFromView: [self rootView]];
}

- (void)showAsActionSheetFromView:(UIView*)v {
    self.sheet = [[UIActionSheet alloc] initWithTitle:@"Chromecast"
                                                       delegate:self
                                              cancelButtonTitle:nil
                                         destructiveButtonTitle:nil otherButtonTitles:nil, nil];
    for (GCKDevice *device in self.devices) {
        BOOL isSelectedDevice = (device == self.manager.activeDevice || (device == self.manager.localDevice && self.manager.activeDevice == nil));
        [self.sheet addButtonWithTitle:[NSString stringWithFormat:@"%@%@", device.friendlyName, (isSelectedDevice) ?  @" ✓" : @""]];
    }
    [self.sheet addButtonWithTitle:@"Cancel"];
    [self.sheet setCancelButtonIndex:[self.devices count] ];
    [self.sheet showInView:v];
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [[NSNotificationCenter defaultCenter] postNotificationName:CTChromecastDeviceListShow object:self];
    });
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    //self.selectionHandler(nil);
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [[NSNotificationCenter defaultCenter] postNotificationName:CTChromecastDeviceListHide object:self];
    });
    self.sheet.delegate = nil;    
    self.sheet = nil;

    if (buttonIndex == actionSheet.cancelButtonIndex) {
        self.selectionHandler(nil);
    } else {
        self.selectionHandler([self.devices objectAtIndex: buttonIndex]);
    }
}

#pragma mark -
#pragma mark Popover
#pragma mark -
- (void)showAsPopoverFromView:(UIView*)view {
    UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController: self];
    [popover presentPopoverFromRect:view.frame inView:view.superview permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    self.currentPopover = popover;
    self.currentPopover.delegate = self;    
}


- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    self.currentPopover = nil;
}

- (void)dismissPopover {
    [self.currentPopover dismissPopoverAnimated:YES];
    self.currentPopover = nil;
}

#pragma mark -
#pragma mark Modal
#pragma mark -
- (void)showAsModal {
    self.currentModal = [[UINavigationController alloc] initWithRootViewController: self];
    self.currentModal.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                                target:self
                                                                                                action:@selector(dismissModal)];
    UIWindow *w = [[UIApplication sharedApplication].windows objectAtIndex:0];
    [w.rootViewController presentViewController: self.currentModal animated:YES completion:nil];
}

- (void)dismissModal {
    [self.currentModal dismissViewControllerAnimated:YES completion:^(void) {
        self.currentModal = nil;
    }];
}


@end
