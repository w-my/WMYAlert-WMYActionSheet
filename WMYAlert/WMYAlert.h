//
//  WMYAlert.h
//  WMYAlert
//
//  Created by Wmy on 16/3/21.
//  Copyright © 2016年 Wmy. All rights reserved.
//
//  https://github.com/Wmy6611?tab=repositories
//

#import <UIKit/UIKit.h>

typedef void (^CancelBlock)();
typedef void (^ConfirmBlock)();

@interface WMYAlert : NSObject

@property (nonatomic, copy) CancelBlock cancelBlock;
@property (nonatomic, copy) ConfirmBlock confirmBlock;

+ (WMYAlert *)sharedInstance;

- (void)showWithParentViewController:(UIViewController *)parentVC
                               title:(NSString *)title
                             message:(NSString *)message
                   cancelButtonTitle:(NSString *)cancelButtonTitle
                  confirmButtonTitle:(NSString *)confirmButtonTitle
                        confirmBlock:(ConfirmBlock)confirm
                         cancelBlock:(CancelBlock)cancel;

@end
