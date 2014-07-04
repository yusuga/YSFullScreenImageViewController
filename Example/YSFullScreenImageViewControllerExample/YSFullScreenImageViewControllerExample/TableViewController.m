//
//  TableViewController.m
//  YSFullScreenImageViewControllerExample
//
//  Created by Yu Sugawara on 2014/07/04.
//  Copyright (c) 2014年 Yu Sugawara. All rights reserved.
//

#import "TableViewController.h"
#import "YSFullScreenImageViewController.h"

@interface TableViewController () <UINavigationControllerDelegate>

@end

@implementation TableViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.delegate = self;
}

- (IBAction)imageViewDidTap:(UITapGestureRecognizer *)sender
{
    UIImageView *imageView = (id)sender.view;
    NSLog(@"tap %@", imageView);
    [YSFullScreenImageViewController presentWithTargetPreviewVew:imageView
                                                           image:imageView.image
                                      shownActivityIndicatorView:NO
                                                      completion:^{
                                                          NSLog(@"completion");
                                                      }];
}

#pragma mark - UINavigationControllerDelegate

- (NSUInteger)navigationControllerSupportedInterfaceOrientations:(UINavigationController *)navigationController
{
    return UIInterfaceOrientationMaskAll;
}

@end
