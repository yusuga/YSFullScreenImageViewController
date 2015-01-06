//
//  YSFullScreenImageViewController.h
//  YSFullScreenImageViewControllerSample
//
//  Created by Neko on 2013/05/02.
//  Copyright (c) 2013年 Yu Sugawara. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YSFullScreenImageViewController : UIViewController

+ (instancetype)presentWithTargetPreviewVew:(UIView*)previewView
                                      image:(UIImage*)image
                 shownActivityIndicatorView:(BOOL)shownActivityIndicatorView
                          presentCompletion:(void(^)(void))presentCompletion
                          dismissCompletion:(void(^)(void))dismissCompletion;

- (void)setImage:(UIImage *)image;

@end