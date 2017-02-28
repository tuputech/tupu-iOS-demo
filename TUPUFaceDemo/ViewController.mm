//
//  ViewController.m
//  TUPUFaceDemo
//
//  Created by drakeDan on 10/01/2017.
//  Copyright © 2017 tupu. All rights reserved.
//

#import "ViewController.h"
#import <GPUImage/GPUImageFramework.h>
#import <tuputechSDK/TPTechSDK.h>
#import "stickerGallery/StickerCollectionViewCell.h"

@interface ViewController ()<TPRenderingDelegate, UICollectionViewDelegate, UICollectionViewDataSource>
@property (nonatomic, strong) GPUImageVideoCamera *videoCamera;
@property (nonatomic, strong) GPUImageView *filterView;

@property (nonatomic, copy) NSArray<id<TPStickerInfo>> *stickers;
@property (nonatomic, strong) GPUImageFilterGroup *beautifyFilter;
@property (nonatomic, strong) GPUImageFilter<TPReceiveFaceKeyPointProtocol> *stickerFilter;
@property (nonatomic, strong) GPUImageFilter<TPReceiveFaceKeyPointProtocol, TPSetRenderEventDelegateProtocol> *landmarkFilter;

@property (weak, nonatomic) IBOutlet UICollectionView *stickerGalleryView;
@property (weak, nonatomic) IBOutlet UIButton *backTapBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *stickerGalleryConstraint;

@property (weak, nonatomic) IBOutlet UIView *debugView;
@property (weak, nonatomic) IBOutlet UIImageView *debugImageView;
@property (weak, nonatomic) IBOutlet UILabel *debugInfoView;
@property (weak, nonatomic) IBOutlet UIView *HUDView;
@property (weak, nonatomic) IBOutlet UIButton *close;
@end

@implementation ViewController{
//    TUPULandmark *_tupu;
    id<TPLandmarkServiceInterface> _landmarkService;
    id<TPRenderServiceInterface> _renderService;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [TPTechSDK createService:TPFaceCheckService complete:^(id service, NSError *error) {
        if (!error) {
            _landmarkService = (id<TPLandmarkServiceInterface>)service;
            [_landmarkService setFaceRectDebugScale:self.boxScale];
            [_landmarkService enableDebugMode:YES];
            [self tryStartupVideoCamera];
        }
        else {
            id<TPSDKAuthInterface> authService = [TPTechSDK createTPAuthService];
            [authService autoInstallLicenseBySDKWithAppkey:@"f54b76527835ba62337c9e535d01590d" appSecret:@"8ed03bf9f6687ae7344923898794277f25248d3c" serviceIDs:@[@(TPFaceCheckService)] complete:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    [TPTechSDK createService:TPFaceCheckService complete:^(id service, NSError *error) {
                        if (!error) {
                            _landmarkService = (id<TPLandmarkServiceInterface>)service;
                            [_landmarkService setFaceRectDebugScale:self.boxScale];
                            [_landmarkService enableDebugMode:YES];
                            [self tryStartupVideoCamera];
                        }
                    }];
                }
            }];
        }
    }];
    
    [TPTechSDK createService:TPRenderingService complete:^(id service, NSError *error) {
        if (!error) {
            _renderService = (id<TPRenderServiceInterface>)service;
            self.beautifyFilter = [_renderService createTPBeautifyFilter];
            self.stickerFilter = [_renderService createStickerFilter];
            self.landmarkFilter = [_renderService createTPLandmarkFilter];
            [self tryStartupVideoCamera];
        }
    }];

    if (!self.debugMode) {
        self.debugView.hidden = YES;
    }
    [self p_configSubView];
}

- (void)tryStartupVideoCamera {
    if (_landmarkService && _renderService && _beautifyFilter && _stickerFilter && _landmarkFilter) {
        [self p_initGPUImageFilters];
        [self.videoCamera startCameraCapture];
    }
}

#pragma mark -
#pragma mark ------------ Private Functions ------------
- (void)p_configSubView {
    _stickerGalleryView.delegate = self;
    _stickerGalleryView.dataSource = self;
    
    UICollectionViewFlowLayout *flow = (UICollectionViewFlowLayout*)_stickerGalleryView.collectionViewLayout;
    flow.sectionInset = UIEdgeInsetsMake(0, 5, 0, 5);
}

- (void)p_initGPUImageFilters {
    self.videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:AVCaptureDevicePositionFront];
    self.videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    self.videoCamera.horizontallyMirrorFrontFacingCamera = YES;
    
    self.filterView = [[GPUImageView alloc] initWithFrame:self.view.bounds];
    self.filterView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
    self.filterView.center = self.view.center;
    
    [self.view insertSubview:self.filterView belowSubview:self.HUDView];
    
    [_landmarkFilter setReceiveRenderEventDelegate:self];
    
    [self.videoCamera addTarget: self.beautifyFilter];
    [self.beautifyFilter addTarget:self.landmarkFilter];
    [self.landmarkFilter addTarget:self.stickerFilter];
    [self.stickerFilter addTarget:self.filterView];
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    tapRecognizer.numberOfTapsRequired = 2;
    [self.HUDView addGestureRecognizer:tapRecognizer];
    
    [self.close addTarget:self action:@selector(handleClose:) forControlEvents:UIControlEventTouchUpInside];
    
    [_renderService loadStickerWithPath:@"" complete:^(NSArray<id<TPStickerInfo>> *result, NSError *err) {
        if (!err) {
            self.stickers = [result copy];
        }
    }];
}

#pragma mark -
#pragma mark ------------ UICollectionViewDelegate, UICollectionViewDelegate ------------
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [_stickers count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TPStickerCell" forIndexPath:indexPath];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = indexPath.row;
    [_renderService renderStickerWithIndex:row];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {}

#pragma --
#pragma mark - <UICollectionViewDelegateFlowLayout>
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(80, 100); // SCREEN_WIDTH / 4
}

- (UIEdgeInsets)collectionView:(UICollectionView*)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(10, 5, 10, 5); // top, left, bottom, right
}

- (void)handleClose:(id)sender {
    [self.videoCamera stopCameraCapture];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) handleTap:(id)sender {
//    self.landmarkFilter.debugMode = !self.landmarkFilter.debugMode;
}

- (IBAction)backTapBtnClicked:(id)sender {
    NSLog(@"backTapBtnClicked");
    [self.view layoutIfNeeded];
    if (self.stickerGalleryConstraint.constant == 0) {
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionTransitionCurlDown animations:^{
            self.stickerGalleryConstraint.constant = -128;
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            
        }];
    }
    else {
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionTransitionCurlDown animations:^{
            self.stickerGalleryConstraint.constant = 0;
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            
        }];
    }

}

- (IBAction)switchCameraBtnClicked:(id)sender {
    NSLog(@"switchCameraBtnClicked");
    [_videoCamera rotateCamera];
}

#pragma mark - TPRenderDelegate

- (void)TPRenderer:(GPUImageOutput *)renderer WillBeginRender:(GPUImageFramebuffer *)buffer {
    if (renderer == self.landmarkFilter) {
        [buffer lock];
        CVPixelBufferRef pixelBuffer = buffer.pixelBuffer;
        CFRetain(pixelBuffer);
        CMFormatDescriptionRef outputFormatDescription = NULL;
        CMVideoFormatDescriptionCreateForImageBuffer(kCFAllocatorDefault, pixelBuffer, &outputFormatDescription);
        
        [_landmarkService faceCheckAndLandmark:pixelBuffer smoothEnable:_smoothEnabled complete:^(NSError *error, BOOL isFace, NSArray<NSValue*> *keyPoints, CGRect rect) {
            if (isFace) {
                [_stickerFilter updateFaceKeyPoint:@[keyPoints]];
                [_landmarkFilter updateFaceKeyPoint:keyPoints];
                [_landmarkFilter updateFaceRect:rect];
            } else {
                [_stickerFilter updateFaceKeyPoint:@[]];
                [_landmarkFilter updateFaceKeyPoint:@[]];
                [_landmarkFilter updateFaceRect:CGRectNull];
            }
        } debug:^(NSString *debugInfo, UIImage *debugImg) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (debugInfo) {
                    self.debugInfoView.text = debugInfo;
                }
                
                if (debugImg) {
                    [self.debugImageView setImage:debugImg];
                }
            });

        }];
        
        CFRelease(pixelBuffer);
        [buffer unlock];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
