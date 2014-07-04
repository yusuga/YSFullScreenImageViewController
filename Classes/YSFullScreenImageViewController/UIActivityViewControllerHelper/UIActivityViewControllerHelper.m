//
//  UIActivityViewControllerHelper.m
//  YSFullScreenImageViewControllerSample
//
//  Created by Neko on 2013/05/02.
//  Copyright (c) 2013年 Yu Sugawara. All rights reserved.
//

#import "UIActivityViewControllerHelper.h"
#import "LINEActivity.h"

@implementation UIActivityViewControllerHelper

+ (void)presentUIActivityViewControllerToPresentingViewController:(UIViewController*)pvc item:(id)item
{
    NSAssert1([item isKindOfClass:[NSString class]] || [item isKindOfClass:[UIImage class]] , @"item != NSString class || item != UIImage class; item class = %@", [item class]);
    UIActivityViewController *avc = [[UIActivityViewController alloc] initWithActivityItems:@[item] applicationActivities:@[[[LINEActivity alloc] init]]];
    avc.excludedActivityTypes = @[UIActivityTypePostToTwitter, UIActivityTypePostToFacebook, UIActivityTypePostToWeibo, UIActivityTypeMail, UIActivityTypeMessage, UIActivityTypeAssignToContact];
    [pvc presentViewController:avc animated:YES completion:nil];
}

@end