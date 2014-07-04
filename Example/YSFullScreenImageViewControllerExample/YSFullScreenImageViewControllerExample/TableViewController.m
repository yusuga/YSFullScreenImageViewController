//
//  TableViewController.m
//  YSFullScreenImageViewControllerExample
//
//  Created by Yu Sugawara on 2014/07/04.
//  Copyright (c) 2014年 Yu Sugawara. All rights reserved.
//

#import "TableViewController.h"
#import "YSFullScreenImageViewController.h"

@interface TableViewController ()

@end

@implementation TableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

@end
