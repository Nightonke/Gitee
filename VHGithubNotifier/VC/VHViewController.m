//
//  VHViewController.m
//  VHGithubNotifier
//
//  Created by viktorhuang on 2017/2/22.
//  Copyright © 2017年 黄伟平. All rights reserved.
//

#import "VHViewController.h"

@interface VHViewController ()

@end

@implementation VHViewController

- (void)addNotification:(NSString *)name forSelector:(SEL)selector
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:selector
                                                 name:name
                                               object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
