//
//  VHCursorButton+AFNetworking.h
//  VHGithubNotifier
//
//  Created by viktorhuang on 2017/3/9.
//  Copyright © 2017年 黄伟平. All rights reserved.
//

#import "VHCursorButton.h"
#import "AFImageDownloader.h"

@interface VHCursorButton (AFNetworking)

+ (void)setSharedImageDownloader:(AFImageDownloader *)imageDownloader;

+ (AFImageDownloader *)sharedImageDownloader;

- (void)setImageWithURL:(NSURL *)url;

- (void)setImageWithURL:(NSURL *)url
       placeholderImage:(nullable NSImage *)placeholderImage;

- (void)setImageWithURLRequest:(NSURLRequest *)urlRequest
              placeholderImage:(nullable NSImage *)placeholderImage
                       success:(nullable void (^)(NSURLRequest *request, NSHTTPURLResponse * _Nullable response, NSImage *image))success
                       failure:(nullable void (^)(NSURLRequest *request, NSHTTPURLResponse * _Nullable response, NSError *error))failure;

- (void)cancelImageDownloadTask;

@end
