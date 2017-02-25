//
//  VHSecureTextField.m
//  VHGithubNotifier
//
//  Created by viktorhuang on 2017/2/25.
//  Copyright © 2017年 黄伟平. All rights reserved.
//

#import "VHSecureTextField.h"

@implementation VHSecureTextField

- (BOOL)performKeyEquivalent:(NSEvent *)event
{
    if ([[event charactersIgnoringModifiers] isEqualToString:@"\r"]
        && self.secureTextFieldDelegate
        && [self.secureTextFieldDelegate respondsToSelector:@selector(onSecureTextFieldEnterButtonClicked:)])
    {
        [self.secureTextFieldDelegate onSecureTextFieldEnterButtonClicked:self];
    }
    return [super performKeyEquivalent:event];
}

@end
