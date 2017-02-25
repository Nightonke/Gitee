//
//  VHTrendingRepositoryCellView.m
//  VHGithubNotifier
//
//  Created by viktorhuang on 2017/2/22.
//  Copyright © 2017年 黄伟平. All rights reserved.
//

#import "VHTrendingRepositoryCellView.h"
#import "VHUtils+TransForm.h"
#import "NSView+Position.h"

@interface VHTrendingRepositoryCellView ()

@property (nonatomic, strong) VHTrendingRepository *repository;
@property (nonatomic, strong) NSTrackingArea *trackingArea;
@property (nonatomic, assign) BOOL hasPressedDown;

@end

@implementation VHTrendingRepositoryCellView

#pragma mark - Public Methods

- (void)awakeFromNib
{
    self.wantsLayer = YES;
    [self.repositoryDescription.cell setLineBreakMode:NSLineBreakByWordWrapping];
    [self.repositoryDescription.cell setTruncatesLastVisibleLine:YES];
    [self.repositoryDescription setMaximumNumberOfLines:2];
    [self.starImage setImage:[NSImage imageNamed:@"icon_repository_star"]];
    [self.forkImage setImage:[NSImage imageNamed:@"icon_repository_fork"]];
    [self.starTrendingImage setImage:[NSImage imageNamed:@"icon_repository_star"]];
    self.hasPressedDown = NO;
}

- (void)setTrendingRepository:(VHTrendingRepository *)trendingRepository
{
    _repository = trendingRepository;
    
    NSMutableAttributedString *nameString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ / %@", self.repository.ownerAccount, self.repository.name]];
    [nameString addAttribute:NSFontAttributeName
                       value:[NSFont systemFontOfSize:16]
                       range:NSMakeRange(0, self.repository.ownerAccount.length + 3)];
    [nameString addAttribute:NSForegroundColorAttributeName
                       value:[VHUtils colorFromHexColorCodeInString:@"#4078c0"]
                       range:NSMakeRange(0, self.repository.ownerAccount.length + 3)];
    [nameString addAttribute:NSFontAttributeName
                       value:[NSFont boldSystemFontOfSize:16]
                       range:NSMakeRange(self.repository.ownerAccount.length + 3, self.repository.name.length)];
    [nameString addAttribute:NSForegroundColorAttributeName
                       value:[VHUtils colorFromHexColorCodeInString:@"#4078c0"]
                       range:NSMakeRange(self.repository.ownerAccount.length + 3, self.repository.name.length)];
    [self.name setAttributedStringValue:nameString];
    
    if ([self.repository.repositoryDescription isEqualToString:@""] == NO)
    {
        [self.repositoryDescription setStringValue:self.repository.repositoryDescription];
        [self.repositoryDescription setToolTip:self.repository.repositoryDescription];
    }
    else
    {
        [self.repositoryDescription setStringValue:@"No description provided."];
        [self.repositoryDescription setToolTip:nil];
    }
    
    if (self.repository.languageName && self.repository.languageColor)
    {
        self.languageDot.languageColor = self.repository.languageColor;
        [self.languageDot setNeedsDisplay:YES];
        [self.language setStringValue:self.repository.languageName];
        [self.language sizeToFit];
        [self.language setVCenter:[self.languageDot getCenterY] + 0.5];
        self.languageDot.hidden = NO;
        self.language.hidden = NO;
        [self.starImage setX:self.language.getRight + 5];
    }
    else
    {
        self.languageDot.hidden = YES;
        self.language.hidden = YES;
        [self.starImage setX:self.languageDot.getLeft];
    }
    
    if ([self.repository.starNumber isEqualToString:@"0"] == NO)
    {
        [self.starText setStringValue:self.repository.starNumber];
        [self.starText sizeToFit];
        [self.starText setVCenter:[self.languageDot getCenterY] + 0.5];
        self.starImage.hidden = NO;
        self.starText.hidden = NO;
        [self.starText setX:self.starImage.getRight + 1];
        [self.forkImage setX:self.starText.getRight + 5];
    }
    else
    {
        self.starImage.hidden = YES;
        self.starText.hidden = YES;
        [self.starText setX:self.starImage.getRight + 1];
        [self.forkImage setX:self.starImage.getLeft];
    }
    
    if ([self.repository.forkNumber isEqualToString:@"0"] == NO)
    {
        [self.forkText setStringValue:self.repository.forkNumber];
        [self.forkText sizeToFit];
        [self.forkText setVCenter:[self.languageDot getCenterY] + 0.5];
        self.forkImage.hidden = NO;
        self.starText.hidden = NO;
    }
    else
    {
        self.forkImage.hidden = YES;
        self.forkText.hidden = YES;
    }
    [self.forkText setX:self.forkImage.getRight + 1];
    
    if (self.repository.trendingTip)
    {
        [self.starTrendingText setStringValue:self.repository.trendingTip];
        [self.starTrendingText sizeToFit];
        [self.starTrendingText setVCenter:[self.languageDot getCenterY] + 0.5];
        [self.starTrendingText setX:self.width - self.starTrendingText.width - 15];
        [self.starTrendingImage setX:self.starTrendingText.getLeft - 1 - self.starTrendingImage.width];
        self.starTrendingImage.hidden = NO;
        self.starTrendingText.hidden = NO;
    }
    else
    {
        self.starTrendingImage.hidden = YES;
        self.starTrendingText.hidden = YES;
    }
    
    NSString *toolTip = [NSString stringWithFormat:@"Click to visit %@ in browser.", self.repository.name];
    [self setToolTip:toolTip];
    [self.languageDot setToolTip:toolTip];
    [self.language setToolTip:toolTip];
    [self.starImage setToolTip:toolTip];
    [self.starText setToolTip:toolTip];
    [self.forkImage setToolTip:toolTip];
    [self.forkText setToolTip:toolTip];
    [self.starTrendingImage setToolTip:toolTip];
    [self.starTrendingText setToolTip:toolTip];
}

- (void)drawRect:(NSRect)dirtyRect
{
    if (self.isLastRow == NO)
    {
        NSBezierPath *line = [NSBezierPath bezierPath];
        [line moveToPoint:NSMakePoint(15, 0)];
        [line lineToPoint:NSMakePoint(NSMaxX([self bounds]) - 15, 0)];
        [line setLineWidth:1.0];
        [[VHUtils colorFromHexColorCodeInString:@"#dfdfdf"] set];
        [line stroke];        
    }
}

- (void)setIsLastRow:(BOOL)isLastRow
{
    _isLastRow = isLastRow;
}

- (void)mouseUp:(NSEvent *)event
{
    self.layer.backgroundColor = [NSColor whiteColor].CGColor;
    if (self.hasPressedDown && self.delegate && [self.delegate respondsToSelector:@selector(onTrendingClicked:)])
    {
        [self.delegate onTrendingClicked:self.repository];
    }
    self.hasPressedDown = NO;
}

- (void)mouseDown:(NSEvent *)event
{
    self.layer.backgroundColor = [VHUtils colorFromHexColorCodeInString:@"#eeeeee"].CGColor;
    self.hasPressedDown = YES;
}

- (void)mouseExited:(NSEvent *)event
{
    self.layer.backgroundColor = [NSColor whiteColor].CGColor;
}

- (void)updateTrackingAreas
{
    if(self.trackingArea != nil)
    {
        [self removeTrackingArea:self.trackingArea];
    }
    
    int opts = (NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways);
    self.trackingArea = [[NSTrackingArea alloc] initWithRect:[self bounds]
                                                     options:opts
                                                       owner:self
                                                    userInfo:nil];
    [self addTrackingArea:self.trackingArea];
}

@end
