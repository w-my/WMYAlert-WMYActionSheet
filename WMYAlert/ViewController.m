//
//  ViewController.m
//  WMYAlert
//
//  Created by Wmy on 16/3/21.
//  Copyright © 2016年 Wmy. All rights reserved.
//


#import "ViewController.h"
#import "WMYAlert.h"
#import "WMYActionSheet.h"

@interface ViewController () <WMYActionSheetDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

}

- (IBAction)action_alert:(id)sender {
    [[WMYAlert sharedInstance] showWithParentViewController:self title:@"title" message:@"message" cancelButtonTitle:@"cancel" confirmButtonTitle:@"confirm" confirmBlock:^{
        NSLog(@"confirm");
    } cancelBlock:^{
        NSLog(@"cancel");
    }];
}

- (IBAction)action_actionSheet:(id)sender {
    WMYActionSheet *actionSheet = [[WMYActionSheet alloc] initWithTitle:@"title" delegate:self cancelButtonTitle:@"cancel" destructiveButtonTitle:@"destructiveBtn" otherButtonTitles:@"message1", @"message2", nil];
    [actionSheet show];
}

#pragma mark -
#pragma mark - WMYActionSheetDelegate

- (void)actionSheet:(WMYActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSLog(@"index: %lu", buttonIndex);
}

@end
