//
//  YSFullScreenImageViewController.h
//  YSFullScreenImageViewControllerSample
//
//  Created by Neko on 2013/05/02.
//  Copyright (c) 2013年 Yu Sugawara. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YSFullScreenImageViewController : NSObject

+ (instancetype)presentWithTargetPreviewVew:(UIView*)previewView
                                      image:(UIImage*)image
                 shownActivityIndicatorView:(BOOL)shownActivityIndicatorView
                                 completion:(void (^)(void))completion;

- (void)setImage:(UIImage *)image;

@end