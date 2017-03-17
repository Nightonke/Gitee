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
    
    if (([event modifierFlags] & NSDeviceIndependentModifierFlagsMask) == NSCommandKeyMask)
    {
        // The command key is the ONLY modifier key being pressed.
        if ([[event charactersIgnoringModifiers] isEqualToString:@"x"])
        {
            return [NSApp sendAction:@selector(cut:) to:[[self window] firstResponder] from:self];
        }
        else if ([[event charactersIgnoringModifiers] isEqualToString:@"c"])
        {
            return [NSApp sendAction:@selector(copy:) to:[[self window] firstResponder] from:self];
        }
        else if ([[event charactersIgnoringModifiers] isEqualToString:@"v"])
        {
            return [NSApp sendAction:@selector(paste:) to:[[self window] firstResponder] from:self];
        }
        else if ([[event charactersIgnoringModifiers] isEqualToString:@"a"])
        {
            return [NSApp sendAction:@selector(selectAll:) to:[[self window] firstResponder] from:self];
        }
    }
    
    return [super performKeyEquivalent:event];
}

@end
