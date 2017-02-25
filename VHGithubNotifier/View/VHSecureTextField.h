//
//  VHSecureTextField.h
//  VHGithubNotifier
//
//  Created by viktorhuang on 2017/2/25.
//  Copyright © 2017年 黄伟平. All rights reserved.
//

@class VHSecureTextField;

@protocol VHSecureTextFieldDelegate <NSObject>

@required
- (void)onSecureTextFieldEnterButtonClicked:(VHSecureTextField *)textField;

@end

@interface VHSecureTextField : NSSecureTextField

@property (nonatomic, weak) id<VHSecureTextFieldDelegate> secureTextFieldDelegate;

@end
