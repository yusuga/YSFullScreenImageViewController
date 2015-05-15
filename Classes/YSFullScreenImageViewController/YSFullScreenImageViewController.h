//
//  YSFullScreenImageViewController.h
//  YSFullScreenImageViewControllerSample
//
//  Created by Neko on 2013/05/02.
//  Copyright (c) 2013年 Yu Sugawara. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface YSFullScreenImageViewController : UIViewController

+ (YSFullScreenImageViewController * __nullable)presentWithTargetPreviewVew:(UIView *)previewView
                                                                      image:(UIImage *)image
                                                 shownActivityIndicatorView:(BOOL)shownActivityIndicatorView
                                                          presentCompletion:(void(^ __nullable)(void))presentCompletion
                                                          dismissCompletion:(void(^ __nullable)(void))dismissCompletion;

- (void)setImage:(UIImage *)image;

@end
NS_ASSUME_NONNULL_END