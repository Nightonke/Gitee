//
//  VHTableView.h
//  VHGithubNotifier
//
//  Created by Nightonke on 2017/9/24.
//  Copyright © 2017年 黄伟平. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface VHTableView : NSTableView

- (void)scrollRowToVisible:(NSInteger)rowIndex animate:(BOOL)animate;

@end
