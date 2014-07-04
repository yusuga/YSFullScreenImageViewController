//
//  UIActivityViewController+YSRotation.m
//  YSFullScreenImageViewControllerSample
//
//  Created by Yu Sugawara on 2013/03/04.
//  Copyright (c) 2013年 Yu Sugawara. All rights reserved.
//

#import "UIActivityViewController+YSRotation.h"

@implementation UIActivityViewController (YSRotation)

- (NSUInteger)supportedInterfaceOrientations
{
    return [self.presentingViewController supportedInterfaceOrientations];
}

- (BOOL)shouldAutorotate{
    return [self.presentingViewController shouldAutorotate];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return [self.presentingViewController preferredInterfaceOrientationForPresentation];
}

@end