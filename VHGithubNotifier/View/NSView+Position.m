//
//  NSView+Position.m
//  QMCGIProtocolAnalyseTool
//
//  Created by viktorhuang on 2016/12/21.
//  Copyright © 2016年 Tencent. All rights reserved.
//

#import "NSView+Position.h"

@implementation NSView (Position)

- (CGFloat)getTop
{
    return self.frame.origin.y;
}

- (CGFloat)getLeft
{
    return self.frame.origin.x;
}

- (CGFloat)getWidth
{
    return self.frame.size.width;
}

- (CGFloat)getHeight
{
    return self.frame.size.height;
}

- (CGFloat)getRight
{
    return self.frame.origin.x + self.frame.size.width;
}

- (CGFloat)getBottom
{
    return self.frame.origin.y + self.frame.size.height;
}

- (CGFloat)getCenterX
{
    return [self getLeft] + [self width] / 2;
}

- (CGFloat)getCenterY
{
    return [self getTop] + [self height] / 2;
}

- (void)setTop:(CGFloat)top
{
    CGRect rect = self.frame;
    rect.origin.y = top;
    self.frame = rect;
}

- (void)setLeft:(CGFloat)left
{
    CGRect rect = self.frame;
    rect.origin.x = left;
    self.frame = rect;
}

- (void)setLeftTop:(CGPoint)leftTop
{
    CGRect rect = self.frame;
    rect.origin.x = leftTop.x;
    rect.origin.y = leftTop.y;
    self.frame = rect;
}

- (CGPoint)origin {
    return self.frame.origin;
}

- (void)setOrigin:(CGPoint) point {
    self.frame = CGRectMake(point.x, point.y, self.frame.size.width, self.frame.size.height);
}

- (CGSize)size {
    return self.frame.size;
}

- (void)setSize:(CGSize) size {
    self.frame = CGRectMake(self.x, self.y, size.width, size.height);
}

- (CGFloat)x {
    return self.frame.origin.x;
}

- (void)setX:(CGFloat)x {
    self.frame = CGRectMake(x, self.y, self.width, self.height);
}

- (CGFloat)y {
    return self.frame.origin.y;
}
- (void)setY:(CGFloat)y {
    self.frame = CGRectMake(self.x, y, self.width, self.height);
}

- (CGFloat)height {
    return self.frame.size.height;
}
- (void)setHeight:(CGFloat)height {
    self.frame = CGRectMake(self.x, self.y, self.width, height);
}

- (CGFloat)width {
    return self.frame.size.width;
}
- (void)setWidth:(CGFloat)width {
    self.frame = CGRectMake(self.x, self.y, width, self.height);
}

- (void)setWidth:(CGFloat)width height:(CGFloat)height
{
    self.frame = CGRectMake(self.x, self.y, width, height);
}

// 横向设置，同时设定x和宽度
- (void) setLeft:(CGFloat)left width:(CGFloat)width
{
    CGRect frame = self.frame;
    self.frame = CGRectMake(left, CGRectGetMinY(frame), width, CGRectGetHeight(frame));
}

// 垂直设置，同时设定y和高度
- (void) setTop:(CGFloat)top height:(CGFloat)height
{
    CGRect frame = self.frame;
    self.frame = CGRectMake(CGRectGetMinX(frame), top, CGRectGetWidth(frame), height);
}

- (void) setVCenter:(CGFloat)vCenter
{
    CGRect frame = self.frame;
    frame.origin.y = vCenter - CGRectGetHeight(frame) / 2.0f;
    self.frame = frame;
}

- (void) setHCenter:(CGFloat)hCenter
{
    CGRect frame = self.frame;
    frame.origin.x = hCenter - CGRectGetWidth(frame) / 2.0f;
    self.frame = frame;
}

- (NSRect)frameRelativeToWindow
{
    return [self convertRect:self.bounds toView:nil];
}

- (NSRect)frameRelativeToScreen
{
    return [self.window convertRectToScreen:[self frameRelativeToWindow]];
}

@end
