//
//  VHTextField.m
//  VHGithubNotifier
//
//  Created by viktorhuang on 2017/2/25.
//  Copyright © 2017年 黄伟平. All rights reserved.
//

#import "VHTextField.h"

@implementation VHTextField

- (BOOL)performKeyEquivalent:(NSEvent *)event
{
    if ([[event charactersIgnoringModifiers] isEqualToString:@"\r"]
        && self.textFieldDelegate
        && [self.textFieldDelegate respondsToSelector:@selector(onTextFieldEnterButtonClicked:)])
    {
        [self.textFieldDelegate onTextFieldEnterButtonClicked:self];
    }
    return [super performKeyEquivalent:event];
}

@end
