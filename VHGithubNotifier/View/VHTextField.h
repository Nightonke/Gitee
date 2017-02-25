//
//  VHTextField.h
//  VHGithubNotifier
//
//  Created by viktorhuang on 2017/2/25.
//  Copyright © 2017年 黄伟平. All rights reserved.
//

@class VHTextField;

@protocol VHTextFieldDelegate <NSObject>

@required
- (void)onTextFieldEnterButtonClicked:(VHTextField *)textField;

@end

@interface VHTextField : NSTextField

@property (nonatomic, weak) id<VHTextFieldDelegate> textFieldDelegate;

@end
