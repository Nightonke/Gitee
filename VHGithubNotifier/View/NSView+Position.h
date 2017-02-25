//
//  NSView+Position.h
//  QMCGIProtocolAnalyseTool
//
//  Created by viktorhuang on 2016/12/21.
//  Copyright © 2016年 Tencent. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSView (Position)

- (CGFloat)getTop;
- (CGFloat)getLeft;
- (CGFloat)getRight;
- (CGFloat)getBottom;
- (CGFloat)getWidth;
- (CGFloat)getHeight;
- (CGFloat)getCenterX;
- (CGFloat)getCenterY;
- (void)setTop:(CGFloat)top;
- (void)setLeft:(CGFloat)left;
- (void)setLeftTop:(CGPoint)leftTop;
- (CGPoint)origin;
- (void)setOrigin:(CGPoint) point;

- (CGSize)size;
- (void)setSize:(CGSize) size;

- (CGFloat)x;
- (void)setX:(CGFloat)x;

- (CGFloat)y;
- (void)setY:(CGFloat)y;

- (CGFloat)height;
- (void)setHeight:(CGFloat)height;

- (CGFloat)width;
- (void)setWidth:(CGFloat)width;

// 横向设置，同时设定x和宽度
- (void) setLeft:(CGFloat)left width:(CGFloat)width;

// 垂直设置，同时设定y和高度
- (void) setTop:(CGFloat)top height:(CGFloat)height;

// 同时设定宽和高
- (void)setWidth:(CGFloat)width height:(CGFloat)height;

// 设置垂直方向的中心点
- (void) setVCenter:(CGFloat)vCenter;

// 设置水平方向的中心点
- (void) setHCenter:(CGFloat)hCenter;

@end
