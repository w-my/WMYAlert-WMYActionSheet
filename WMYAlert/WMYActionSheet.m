//
//  WMYActionSheet.m
//  WMYAlert
//
//  Created by Wmy on 16/3/21.
//  Copyright © 2016年 Wmy. All rights reserved.
//


#import "WMYActionSheet.h"


static CGFloat const kDuration = 0.26;

static CGFloat const kActionSheetTitleLabelHeight = 34.0;
static CGFloat const kActionSheetBtnHeight = 46.0;

typedef NS_ENUM(NSInteger, ActionSheetButtonType) {
    ActionSheetButtonTypeCancelButton = 0,
    ActionSheetButtonTypeDestructiveButton = 1,
    ActionSheetButtonTypeOtherButtons = 10
};


@interface WMYActionSheet ()
@property (nonatomic, weak) id<WMYActionSheetDelegate> delegate;
@property (nonatomic) ActionSheetButtonType buttonType;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) NSLayoutConstraint *contentViewBottomConstraint;
@property (nonatomic) CGFloat contentH;
@property (nonatomic) CGFloat destructiveButtonBottom;
@property (nonatomic) CGFloat otherButtonBottom;
@end

@implementation WMYActionSheet

- (void)layoutSubviews {
    [super layoutSubviews];
    self.frame = [UIScreen mainScreen].bounds;
}

- (instancetype)initWithTitle:(NSString *)title delegate:(id<WMYActionSheetDelegate>)delegate cancelButtonTitle:(NSString *)cancelButtonTitle destructiveButtonTitle:(NSString *)destructiveButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ...
{
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if (!self) {
        return nil;
    }
    
    if (delegate) {
        self.delegate = delegate;
    }
    
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.01];
    [self addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    
    // 拿到otherButtons的title
    NSMutableArray *otherTitles = [NSMutableArray array];
    va_list argList;
    if (otherButtonTitles)
    {
        [otherTitles addObject:otherButtonTitles];
        id arg;
        va_start(argList, otherButtonTitles);
        while ((arg = va_arg(argList, id)))
        {
            [otherTitles addObject:arg];
        }
        va_end(argList);
    }
    
    [self createWithTitle:title cancelButtonTitle:cancelButtonTitle destructiveButtonTitle:destructiveButtonTitle otherButtonTitles:otherTitles];
    
    return self;
}



#pragma mark - show / dismiss

- (void)show {
    
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [UIView animateWithDuration:kDuration
                         animations:^{
                             self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
                             _contentViewBottomConstraint.constant = 0;
                             [self layoutIfNeeded];
                         } completion:^(BOOL finished) {
                             
                         }];
        
    });
}

- (void)dismiss {
    
    [UIView animateWithDuration:kDuration
                     animations:^{
                         self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.01];
                         _contentViewBottomConstraint.constant = _contentH;
                         [self layoutIfNeeded];
                     }
                     completion:^(BOOL finished){
                         _contentViewBottomConstraint = nil;
                         [_contentView removeFromSuperview];
                         _contentView = nil;
                         [self removeFromSuperview];
                     }];
    
}


#pragma mark -

- (void)action_allBtns:(id)sender {
    
    UIButton *btn = (UIButton *)sender;
    if (!_delegate || ![_delegate respondsToSelector:@selector(actionSheet:clickedButtonAtIndex:)]) {
        return;
    }
    
    if (btn.tag == ActionSheetButtonTypeCancelButton) {
        [_delegate actionSheet:self clickedButtonAtIndex:0];
    }
    else if (btn.tag == ActionSheetButtonTypeDestructiveButton) {
        NSInteger index = 0;
        for (UIView *view in _contentView.subviews) {
            if ([view isKindOfClass:[UIButton class]]) {
                UIButton *button = (UIButton *)view;
                if (button.tag == ActionSheetButtonTypeCancelButton) {
                    index += 1;
                }
            }
        }
        [_delegate actionSheet:self clickedButtonAtIndex:index];
    }else if (btn.tag >= ActionSheetButtonTypeOtherButtons) {
        NSInteger index = 0;
        for (UIView *view in _contentView.subviews) {
            if ([view isKindOfClass:[UIButton class]]) {
                UIButton *button = (UIButton *)view;
                if (button.tag == ActionSheetButtonTypeCancelButton) {
                    index += 1;
                }
                if (button.tag == ActionSheetButtonTypeDestructiveButton) {
                    index += 1;
                }
            }
        }
        index += btn.tag - ActionSheetButtonTypeOtherButtons;
        [_delegate actionSheet:self clickedButtonAtIndex:index];
    }
    [self dismiss];
}

#pragma mark - configure

- (void)createWithTitle:(NSString *)title cancelButtonTitle:(NSString *)cancelButtonTitle destructiveButtonTitle:(NSString *)destructiveButtonTitle otherButtonTitles:(NSArray <NSString *>*)otherButtonTitles
{
    // buttons总高度
    _contentH = 0.0;
    if (title)
        _contentH += kActionSheetTitleLabelHeight;
    
    if (cancelButtonTitle)
        _contentH += kActionSheetBtnHeight + 8;
    
    if (destructiveButtonTitle)
        _contentH += kActionSheetBtnHeight;
    
    _contentH += kActionSheetBtnHeight * otherButtonTitles.count;
    
    
    // UI
    [self addSubview:self.contentView];
    [self createVisvalEffectView];
    
    if (title) {
        [self createLabelWithText:title];
    }
    
    _destructiveButtonBottom = 0.0;
    _otherButtonBottom = 0.0;
    
    if (cancelButtonTitle) {
        _destructiveButtonBottom = kActionSheetBtnHeight + 8;
        _otherButtonBottom =  _destructiveButtonBottom;
        [_contentView addSubview:[self buttonWithTitle:cancelButtonTitle tag:ActionSheetButtonTypeCancelButton]];
    }
    if (destructiveButtonTitle) {
        _otherButtonBottom += kActionSheetBtnHeight;
        [_contentView addSubview:[self buttonWithTitle:destructiveButtonTitle tag:ActionSheetButtonTypeDestructiveButton]];
    }
    [otherButtonTitles enumerateObjectsUsingBlock:^(NSString * _Nonnull title, NSUInteger idx, BOOL * _Nonnull stop) {
        [_contentView addSubview:[self buttonWithTitle:title tag:ActionSheetButtonTypeOtherButtons + idx]];
    }];
    
    
    [self addVFL];
}


- (UIView *)contentView {
    if (_contentView == nil) {
        _contentView = ({
            UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
            view.translatesAutoresizingMaskIntoConstraints = NO;
            view.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.48];
            view;
        });
    }
    return _contentView;
}

- (void)createVisvalEffectView {
    
    UIVisualEffectView *visualEffectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
    visualEffectView.translatesAutoresizingMaskIntoConstraints = NO;
    visualEffectView.alpha = 1.0;
    [_contentView addSubview:visualEffectView];
    
    NSString *vfl3 = @"H:|-0-[visualEffectView]-0-|";
    NSString *vfl4 = @"V:|-0-[visualEffectView]-0-|";
    [_contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vfl3
                                                                         options:NSLayoutFormatDirectionLeadingToTrailing
                                                                         metrics:nil
                                                                           views:@{@"visualEffectView":visualEffectView}]];
    [_contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vfl4
                                                                         options:NSLayoutFormatDirectionLeadingToTrailing
                                                                         metrics:nil
                                                                           views:@{@"visualEffectView":visualEffectView}]];
    
}

- (void)createLabelWithText:(NSString *)title {
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    [label setTranslatesAutoresizingMaskIntoConstraints:NO];
    [label setText:title];
    [label setTextColor:[[UIColor blackColor] colorWithAlphaComponent:0.6]];
    [label setFont:[UIFont systemFontOfSize:14]];
    [label setTextAlignment:NSTextAlignmentCenter];
    [_contentView addSubview:label];
    
    NSString *vfl1 = @"H:|-0-[label]-0-|";
    NSString *vfl2 = @"V:|-0-[label(labelH)]";
    [_contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vfl1
                                                                         options:0
                                                                         metrics:nil
                                                                           views:@{@"label":label}]];
    [_contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vfl2
                                                                         options:0
                                                                         metrics:@{@"labelH":@(kActionSheetTitleLabelHeight)}
                                                                           views:@{@"label":label}]];
}

- (UIButton *)buttonWithTitle:(NSString *)title tag:(NSInteger)tag {
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTranslatesAutoresizingMaskIntoConstraints:NO];
    [button setFrame:CGRectZero];
    [button setTag:tag];
    [button setTitle:title forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    if (tag == ActionSheetButtonTypeDestructiveButton) {
        [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    }else {
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
    [button setBackgroundColor:[[UIColor whiteColor] colorWithAlphaComponent:0.6]];
    [button addTarget:self action:@selector(action_allBtns:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

#pragma mark - VFL

- (void)addVFL {
    
    // contentView
    NSString *vfl1 = @"H:|-0-[contentView]-0-|";
    NSString *vfl2 = @"V:[contentView(contentH)]";
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vfl1
                                                                 options:NSLayoutFormatDirectionLeadingToTrailing
                                                                 metrics:nil
                                                                   views:@{@"contentView" : _contentView}]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vfl2
                                                                 options:NSLayoutFormatDirectionLeadingToTrailing
                                                                 metrics:@{@"contentH" : @(_contentH)}
                                                                   views:@{@"contentView" : _contentView}]];
    _contentViewBottomConstraint = [NSLayoutConstraint constraintWithItem:_contentView
                                                                attribute:NSLayoutAttributeBottom
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:self
                                                                attribute:NSLayoutAttributeBottom
                                                               multiplier:1.0
                                                                 constant:_contentH];
    [NSLayoutConstraint activateConstraints:@[_contentViewBottomConstraint]];
    _contentViewBottomConstraint.active = YES;
    
    
    // all buttons
    for (UIView *view in _contentView.subviews) {
        if ([view isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)view;
            
            if (button.tag == ActionSheetButtonTypeCancelButton) {
                
                NSString *vfl3 = @"H:|-0-[button]-0-|";
                NSString *vfl4 = @"V:[button(buttonH)]-0-|";
                [_contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vfl3
                                                                                     options:NSLayoutFormatDirectionLeadingToTrailing
                                                                                     metrics:nil
                                                                                       views:@{@"button":button}]];
                [_contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vfl4
                                                                                     options:NSLayoutFormatDirectionLeadingToTrailing
                                                                                     metrics:@{@"buttonH":@(kActionSheetBtnHeight)}
                                                                                       views:@{@"button":button}]];
            }
            else if (button.tag == ActionSheetButtonTypeDestructiveButton) {
                
                NSString *vfl3 = @"H:|-0-[button]-0-|";
                NSString *vfl4 = @"V:[button(buttonH)]-buttonBottom-|";
                [_contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vfl3
                                                                                     options:NSLayoutFormatDirectionLeadingToTrailing
                                                                                     metrics:nil
                                                                                       views:@{@"button":button}]];
                [_contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vfl4
                                                                                     options:NSLayoutFormatDirectionLeadingToTrailing
                                                                                     metrics:@{@"buttonH":@(kActionSheetBtnHeight-0.5),
                                                                                               @"buttonBottom":@(_destructiveButtonBottom)}
                                                                                       views:@{@"button":button}]];
                
            }else if (button.tag >= ActionSheetButtonTypeOtherButtons) {
                
                CGFloat bottom = _otherButtonBottom + kActionSheetBtnHeight * (button.tag - ActionSheetButtonTypeOtherButtons);
                NSString *vfl3 = @"H:|-0-[button]-0-|";
                NSString *vfl4 = @"V:[button(buttonH)]-buttonBottom-|";
                [_contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vfl3
                                                                                     options:NSLayoutFormatDirectionLeadingToTrailing
                                                                                     metrics:nil
                                                                                       views:@{@"button":button}]];
                [_contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vfl4
                                                                                     options:NSLayoutFormatDirectionLeadingToTrailing
                                                                                     metrics:@{@"buttonH":@(kActionSheetBtnHeight-0.5),
                                                                                               @"buttonBottom":@(bottom)}
                                                                                       views:@{@"button":button}]];
                
            }
            
        }
    }
}

@end
