//
//  WMYAlert.m
//  WMYAlert
//
//  Created by Wmy on 16/3/21.
//  Copyright © 2016年 Wmy. All rights reserved.
//

#import "WMYAlert.h"

@interface WMYAlert ()
#ifdef __IPHONE_8_0
#else
<UIAlertViewDelegate>
#endif

@end

@implementation WMYAlert

- (void)dealloc {
    NSLog(@"%s", __func__);
}

- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

+ (WMYAlert *)sharedInstance {
    
    static WMYAlert *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[[self class] alloc] init];
    });
    return _instance;
}

- (void)showWithParentViewController:(UIViewController *)parentVC
                               title:(NSString *)title
                             message:(NSString *)message
                   cancelButtonTitle:(NSString *)cancelButtonTitle
                  confirmButtonTitle:(NSString *)confirmButtonTitle
                        confirmBlock:(ConfirmBlock)confirm
                         cancelBlock:(CancelBlock)cancel
{
    
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        if (cancelButtonTitle) {
            [alertVC addAction:[UIAlertAction actionWithTitle:cancelButtonTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                if (cancel) {
                    cancel();
                }
            }]];
        }
        if (confirmButtonTitle) {
            [alertVC addAction:[UIAlertAction actionWithTitle:confirmButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                if (confirm) {
                    confirm();
                }
            }]];
        }
        
        if (parentVC) {
            [parentVC presentViewController:alertVC animated:YES completion:NULL];
        }else {
            [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertVC animated:YES completion:NULL];
        }
        
    }
#ifdef __IPHONE_8_0
#else
    else {
        self.cancelBlock = cancel;
        self.confirmBlock = confirm;
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:cancelButtonTitle otherButtonTitles:confirmButtonTitle, nil];
        [alertView show];
    }
#endif
    
}

#ifdef __IPHONE_8_0
#else

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0 && _cancelBlock) {
        self.cancelBlock();
    }else if (buttonIndex == 1 && _confirmBlock) {
        self.confirmBlock();
    }
    self.cancelBlock = nil;
    self.confirmBlock = nil;
}

#endif

@end

