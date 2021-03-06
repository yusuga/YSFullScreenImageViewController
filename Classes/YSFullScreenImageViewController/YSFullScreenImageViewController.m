//
//  YSFullScreenImageViewController.m
//  YSFullScreenImageViewControllerSample
//
//  Created by Neko on 2013/05/02.
//  Copyright (c) 2013年 Yu Sugawara. All rights reserved.
//

#import "YSFullScreenImageViewController.h"

static CFTimeInterval const kAnimationDuration = 0.2;

static inline CGFLOAT_TYPE CGFloat_fabs(CGFLOAT_TYPE cgfloat) {
#if defined(__LP64__) && __LP64__
    return fabs(cgfloat);
#else
    return fabsf(cgfloat);
#endif
}

@interface YSFullScreenImageViewController () <UIScrollViewDelegate>

@property (nonatomic, weak) UIWindow *previousKeyWindow;
@property (nonatomic) UIWindow *window;
@property (nonatomic) IBOutlet UIView *backgroundColorView;
@property (nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic) CAShapeLayer *imageMaskLayer;
@property (nonatomic) CGRect startFrame;
@property (nonatomic) CGRect endFrame;
@property (nonatomic) BOOL crossDissolveTransition;
@property (nonatomic) UIActivityIndicatorView *activityIndicatorView;

@property (copy, nonatomic) void(^dismissCompletion)(void);

@end

@implementation YSFullScreenImageViewController

+ (YSFullScreenImageViewController * __nullable)presentWithTargetPreviewVew:(UIView*)previewView
                                                                      image:(UIImage*)image
                                                 shownActivityIndicatorView:(BOOL)shownActivityIndicatorView
                                                          presentCompletion:(void(^)(void))presentCompletion
                                                          dismissCompletion:(void(^)(void))dismissCompletion;
{
    if (!image) {
#ifdef DDLogWarn
        DDLogWarn(@"Image is nil. %s", __func__);
#endif
        return nil;
    }
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    if ([window.rootViewController isKindOfClass:[self class]]) {
#ifdef DDLogWarn
        DDLogWarn(@"Already YSFullScreenImageViewController is displayed. %s", __func__);
#endif
        return nil;
    }
    
    YSFullScreenImageViewController *vc = [[YSFullScreenImageViewController alloc] initWithPreviewView:previewView
                                                                                                 image:image
                                                                            shownActivityIndicatorView:shownActivityIndicatorView];
    vc.dismissCompletion = dismissCompletion;
    [vc showWithCompletion:presentCompletion];
    return vc;
}

- (id)initWithPreviewView:(UIView*)previewView
                    image:(UIImage*)image
shownActivityIndicatorView:(BOOL)shownActivityIndicatorView
{
    if (self = [super init]) {
        CGRect previewViewBounds = CGRectZero;
        if (previewView) {
            previewViewBounds = previewView.bounds;
        } else {
            previewViewBounds = CGRectMake(0.f, 0.f, 100.f, 100.f);
        }
        
        self.previousKeyWindow = [UIApplication sharedApplication].keyWindow;
        self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        self.window.windowLevel = UIWindowLevelStatusBar + 1.f;
        
        self.window.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.window.opaque = NO;
        self.window.rootViewController = self;
        self.view.frame = self.window.bounds;        
        
        self.backgroundColorView = [[UIView alloc] initWithFrame:self.view.bounds];
        self.backgroundColorView.backgroundColor = [UIColor blackColor];
        self.backgroundColorView.layer.opacity = 0.f;
        self.backgroundColorView.autoresizingMask = self.view.autoresizingMask;
        [self.view addSubview:self.backgroundColorView];
        
        self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
        self.scrollView.delegate = self;
        [self configureScrollViewContentSize];
        self.scrollView.minimumZoomScale = 1.f;
        self.scrollView.maximumZoomScale = 5.f;
        self.scrollView.autoresizingMask = self.view.autoresizingMask;
        [self.view addSubview:self.scrollView];
        
        self.imageView = [[UIImageView alloc] initWithImage:image];
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        
        CAShapeLayer *maskLayer = [CAShapeLayer layer];
        maskLayer.frame = previewViewBounds;
        maskLayer.path = [UIBezierPath bezierPathWithRect:previewViewBounds].CGPath;
        self.imageMaskLayer = maskLayer;
        self.imageView.layer.mask = maskLayer;
        
        self.imageView.autoresizingMask = self.view.autoresizingMask;
        [self.scrollView addSubview:self.imageView];
        
        CGPoint origin = CGPointZero;
        if (previewView) {
            UIApplication *app = [UIApplication sharedApplication];
            origin = [previewView convertPoint:CGPointZero toView:self.window];
            
            if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_7_1) {
                CGSize winSize = self.window.bounds.size;
                switch (app.statusBarOrientation) {
                    case UIInterfaceOrientationPortrait:
                        break;
                    case UIInterfaceOrientationPortraitUpsideDown:
                        origin.x = winSize.width - origin.x;
                        origin.y = winSize.height - origin.y;
                        break;
                    case UIInterfaceOrientationLandscapeLeft:
                    {
                        CGFloat beforeX = origin.x;
                        origin.x = winSize.height - origin.y;
                        origin.y = beforeX;
                        break;
                    }
                    case UIInterfaceOrientationLandscapeRight:
                    {
                        CGFloat beforeX = origin.x;
                        origin.x = origin.y;
                        origin.y = winSize.width - beforeX;
                        break;
                    }
                    default:
                        self.crossDissolveTransition = YES;
                        break;
                }
            }
        } else {
            self.crossDissolveTransition = YES;
        }
        self.startFrame = CGRectMake(origin.x, origin.y, previewViewBounds.size.width, previewViewBounds.size.height);
        self.imageView.frame = self.startFrame;
                
        if (shownActivityIndicatorView) {
            self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
            self.activityIndicatorView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
            self.activityIndicatorView.center = CGPointMake(self.imageView.bounds.size.width/2.f, self.imageView.bounds.size.height/2.f);
            [self.imageView addSubview:self.activityIndicatorView];
            [self.activityIndicatorView startAnimating];
        }
        
        self.view.userInteractionEnabled = NO;
        [self addGestureRecognizers];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willRotate:) name:UIApplicationWillChangeStatusBarOrientationNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRotate:) name:UIDeviceOrientationDidChangeNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)showWithCompletion:(void(^)(void))completion
{
    [self.window makeKeyAndVisible];
    [self.window addSubview:self.view];
    
    CGSize viewSize = self.view.bounds.size;
    CGSize imageSize = self.imageView.image.size;
    
    BOOL isPortrait = UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation);
    
    CGFloat ratioWidth = viewSize.width/imageSize.width;
    CGFloat ratioHeight = viewSize.height/imageSize.height;

    CGFloat size = 0.f;
    CGPoint maskOrigin = CGPointZero;
    
    if (imageSize.width > 0.f && imageSize.height > 0.f) {
        if (isPortrait) {
            if (imageSize.width < imageSize.height) {
                if (ratioWidth > ratioHeight) {
                    size = imageSize.width*ratioHeight;
                    maskOrigin = CGPointMake(-((viewSize.width - size)/2.f),
                                             -((viewSize.height - size)/2.f));
                } else {
                    size = viewSize.width;
                    maskOrigin = CGPointMake(0.f,
                                             -((viewSize.height - size)/2.f));
                }
            } else {
                size = imageSize.height*ratioWidth;
                maskOrigin = CGPointMake(-((viewSize.width - size)/2.f),
                                         - ((viewSize.height - size)/2.f));
            }
        } else {
            if (imageSize.width < imageSize.height) {
                size = imageSize.width*ratioHeight;
                maskOrigin = CGPointMake(-((viewSize.width - size)/2.f),
                                         -((viewSize.height - size)/2.f));
            } else {
                if (ratioWidth < ratioHeight) {
                    size = imageSize.height*ratioWidth;
                    maskOrigin = CGPointMake(-((viewSize.width - size)/2.f),
                                             -((viewSize.height - size)/2.f));
                } else {
                    size = viewSize.height;
                    maskOrigin = CGPointMake(-((viewSize.width - size)/2.f),
                                             0.f);
                }
            }
        }
    } else {
#ifdef DDLogError
        DDLogError(@"imageSize(%@) is invalid. %s", NSStringFromCGSize(imageSize), __func__);
#endif
    }
    
    __weak typeof(self) wself = self;
    
    if (self.crossDissolveTransition) {
        self.backgroundColorView.alpha = 0.f;
        self.imageView.alpha = 0.f;
        self.imageView.center = CGPointMake(self.view.bounds.size.width/2.f,
                                            self.view.bounds.size.height/2.f);
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        self.imageView.layer.mask = nil;
        
        [UIView animateWithDuration:0.3 animations:^{
            wself.backgroundColorView.alpha = 1.f;
            wself.imageView.alpha = 1.f;
            wself.imageView.frame = wself.view.bounds;
        } completion:^(BOOL finished) {
            wself.view.userInteractionEnabled = YES;
            if (completion) completion();
        }];
    } else {
        [self addAnimationWithImageViewSize:CGSizeMake(size, size)
                            imageViewCenter:CGPointMake(self.view.bounds.size.width/2.f,
                                                        self.view.bounds.size.height/2.f)
                              imageMaskRect:CGRectMake(maskOrigin.x,
                                                       maskOrigin.y,
                                                       self.view.bounds.size.width,
                                                       self.view.bounds.size.height)
                                 completion:^{
                                     wself.endFrame = wself.imageView.frame;
                                     wself.imageView.frame = wself.view.bounds;
                                     wself.imageView.contentMode = UIViewContentModeScaleAspectFit;
                                     wself.imageView.layer.mask = nil;
                                     
                                     wself.view.userInteractionEnabled = YES;
                                     if (completion) completion();
                                 }];
    }
}

- (void)hide
{
    self.view.userInteractionEnabled = NO;
    
    /**
     *  userInteractionEnabled = NO だけでは UITapGestureRecognizerの遅延発動は止められないため
     *  UITapGestureRecognizerを削除する
     */
    [self removeGestureRecognizers];
    
    __weak typeof(self) wself = self;
    void(^cleanUp)(void) = ^{
        __strong typeof(wself) strongSelf = wself;
        
        [strongSelf.view removeFromSuperview];
        [strongSelf.window removeFromSuperview];
        strongSelf.window = nil;
        
        [strongSelf.previousKeyWindow makeKeyAndVisible];
        
        if (strongSelf.dismissCompletion) strongSelf.dismissCompletion();
    };
    
    if (!self.crossDissolveTransition
        && self.scrollView.zoomScale == 1.f) {
        
        self.imageView.frame = self.endFrame;
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.layer.mask = self.imageMaskLayer;
        
        [self addAnimationWithImageViewSize:self.startFrame.size
                            imageViewCenter:CGPointMake(CGRectGetMidX(self.startFrame), CGRectGetMidY(self.startFrame))
                              imageMaskRect:CGRectMake(0.f, 0.f, self.startFrame.size.width, self.startFrame.size.height)
                                 completion:^{
                                     cleanUp();
                                 }];
    } else {
        [UIView animateWithDuration:kAnimationDuration animations:^{
            wself.view.alpha = 0.f;
        }completion:^(BOOL finished) {
            cleanUp();
        }];
    }
}

- (void)addAnimationWithImageViewSize:(CGSize)imageViewSize
                      imageViewCenter:(CGPoint)imageViewCenter
                        imageMaskRect:(CGRect)imageMaskRect
                           completion:(void(^)(void))completion
{
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        if (completion) completion();
    }];
    
    UIBezierPath *imageMaskPath = [UIBezierPath bezierPathWithRect:imageMaskRect];
    
    // backgroundColorView
    {
        CGFloat opacity = !self.backgroundColorView.layer.opacity;
        
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        animation.fromValue = @(!opacity);
        animation.toValue = @(opacity);
        animation.duration = kAnimationDuration;
        
        self.backgroundColorView.layer.opacity = opacity;
        [self.backgroundColorView.layer addAnimation:animation forKey:@"opacity"];
    }
    
    // imageView
    {
        CGRect bounds = CGRectMake(0.f, 0.f, imageViewSize.width, imageViewSize.height);
        
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"bounds"];
        animation.fromValue = [NSValue valueWithCGRect:self.imageView.bounds];
        animation.toValue = [NSValue valueWithCGRect:bounds];
        animation.duration = kAnimationDuration;
        
        self.imageView.layer.bounds = bounds;
        [self.imageView.layer addAnimation:animation forKey:@"bounds"];
    }
    {
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
        animation.fromValue = [NSValue valueWithCGPoint:self.imageView.center];
        animation.toValue = [NSValue valueWithCGPoint:imageViewCenter];
        animation.duration = kAnimationDuration;
        
        self.imageView.layer.position = imageViewCenter;
        [self.imageView.layer addAnimation:animation forKey:@"position"];
    }
    
    // imageMaskLayer
    {
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"path"];
        animation.fromValue = (__bridge id)self.imageMaskLayer.path;
        animation.toValue = (__bridge id)(imageMaskPath.CGPath);
        animation.duration = kAnimationDuration;
        
        self.imageMaskLayer.path = imageMaskPath.CGPath;
        [self.imageMaskLayer addAnimation:animation forKey:@"path"];
    }
    
    // activityIndicatorView
    {
        CGPoint p = CGPointMake(imageViewSize.width/2.f, imageViewSize.height/2.f);
        
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
        animation.fromValue = [NSValue valueWithCGPoint:self.activityIndicatorView.layer.position];
        animation.toValue = [NSValue valueWithCGPoint:p];
        animation.duration = kAnimationDuration;
        
        self.activityIndicatorView.layer.position = p;
        [self.activityIndicatorView.layer addAnimation:animation forKey:@"position"];
    }
    
    [CATransaction commit];
}

- (void)setImage:(UIImage *)image
{
    if (self.activityIndicatorView.isAnimating) {
        [self.activityIndicatorView stopAnimating];
        [self.activityIndicatorView removeFromSuperview];
        self.activityIndicatorView = nil;
    }
    self.imageView.image = image;
}

#pragma mark - Gesture

- (void)addGestureRecognizers
{
    // Single tap
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewDidSingleTap:)]];
    
    // Double tap
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewDidDoubleTap:)];
    doubleTap.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:doubleTap];
    
    // Long press
    [self.view addGestureRecognizer:[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(viewDidLongPress:)]];
}

- (void)removeGestureRecognizers
{
    for (UIGestureRecognizer *gesture in self.view.gestureRecognizers) {
        [self.view removeGestureRecognizer:gesture];
    }
}

- (void)viewDidSingleTap:(UITapGestureRecognizer*)gr
{
    [self performSelector:@selector(hide) withObject:nil afterDelay:0.2];
}

- (void)viewDidDoubleTap:(UITapGestureRecognizer*)gr
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    if (self.scrollView.zoomScale == 1.f) {
        CGPoint p = [gr locationInView:self.view];
        CGFloat w = self.view.bounds.size.width/2.f, h = self.view.bounds.size.height/2.f;
        [self.scrollView zoomToRect:CGRectMake(p.x - w/2.f, p.y - h/2.f, w, h) animated:YES];
    } else {
        [self.scrollView setZoomScale:1.f animated:YES];
    }
}

- (void)viewDidLongPress:(UILongPressGestureRecognizer*)gr
{
    if (self.activityIndicatorView == nil) {
        if (gr.state == UIGestureRecognizerStateBegan) {
            UIActivityViewController *vc = [[UIActivityViewController alloc] initWithActivityItems:@[self.imageView.image]
                                                                             applicationActivities:nil];
            vc.excludedActivityTypes = @[UIActivityTypePostToTwitter, UIActivityTypePostToFacebook, UIActivityTypePostToWeibo, UIActivityTypeMail, UIActivityTypeMessage, UIActivityTypeAssignToContact];
            [self presentViewController:vc animated:YES completion:nil];
        } else if (gr.state == UIGestureRecognizerStateEnded) {
            
        }
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.zoomScale == 1.f) {
        self.backgroundColorView.alpha = 1.f - CGFloat_fabs(scrollView.contentOffset.y)/100.f;
        if (self.backgroundColorView.alpha < 0.6f) self.backgroundColorView.alpha = 0.6f;
    }
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    if (CGSizeEqualToSize(scrollView.contentSize, scrollView.bounds.size)) {
        [self configureScrollViewContentSize];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (scrollView.zoomScale == 1.f && CGFloat_fabs(scrollView.contentOffset.y) > 70.f) {
        self.crossDissolveTransition = YES;
        [self hide];
    }
}

#pragma mark - ScrollView

- (void)configureScrollViewContentSize
{
    self.scrollView.contentSize = CGSizeMake(self.scrollView.bounds.size.width,
                                             self.scrollView.bounds.size.height + 1.f);
}

#pragma mark - Notification

- (void)willRotate:(NSNotification*)notification
{
    self.crossDissolveTransition = YES;
    self.scrollView.zoomScale = 1.f;
}

- (void)didRotate:(NSNotification*)notification
{
    [self configureScrollViewContentSize];
}

#pragma mark - Rotation

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

#pragma mark - StatusBar

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

@end
