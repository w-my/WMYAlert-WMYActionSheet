//
//  WMYActionSheet.h
//  WMYAlert
//
//  Created by Wmy on 16/3/21.
//  Copyright © 2016年 Wmy. All rights reserved.
//
//  https://github.com/Wmy6611?tab=repositories
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class WMYActionSheet;
@protocol WMYActionSheetDelegate <NSObject>
- (void)actionSheet:(WMYActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex;
@end

@interface WMYActionSheet : UIControl

- (instancetype)initWithTitle:(nullable NSString *)title
                     delegate:(nullable id<WMYActionSheetDelegate>)delegate
            cancelButtonTitle:(nullable NSString *)cancelButtonTitle
       destructiveButtonTitle:(nullable NSString *)destructiveButtonTitle
            otherButtonTitles:(nullable NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION;

- (void)show;

@end

NS_ASSUME_NONNULL_END
