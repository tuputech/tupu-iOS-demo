//
//  ViewController.m
//  TUPUFaceDemo
//
//  Created by drakeDan on 10/01/2017.
//  Copyright © 2017 tupu. All rights reserved.
//

#import "ViewController.h"
#import <GPUImage/GPUImageFramework.h>
#import <tupu-sdk/tupu.h>
#import <TPRenderer/TPRenderer.h>
#import <opencv2/opencv.hpp>
#import <opencv2/highgui/ios.h>

@interface ViewController ()<TPRenderingDelegate>
@property (nonatomic, strong) GPUImageVideoCamera *videoCamera;
@property (nonatomic, strong) GPUImageView *filterView;

@property (nonatomic, strong) TPStickerFilter *stickerFilter;
@property (nonatomic, copy) NSArray<TPSticker *> *stickers;

@property (nonatomic, strong) TPLandmarkFilter *landmarkFilter;
@property (nonatomic, strong) TPBeautifyFilter *beautifyFilter;

@property (weak, nonatomic) IBOutlet UIView *debugView;
@property (weak, nonatomic) IBOutlet UIImageView *debugImageView;
@property (weak, nonatomic) IBOutlet UILabel *debugInfoView;
@property (weak, nonatomic) IBOutlet UIView *HUDView;
@property (weak, nonatomic) IBOutlet UIButton *close;

@end

@implementation ViewController{
    TUPULandmark *_tupu;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _tupu = [TUPULandmark new];
    _tupu.debugMode = self.debugMode;
    _tupu.boxScale = self.boxScale;
    if (![_tupu initWithModel:@"tupu_face_1_0_0.model"]) {
        NSLog(@"Failed to initialize model");
        return;
    }

    if (!self.debugMode) {
        self.debugView.hidden = YES;
    }
    
    self.videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:AVCaptureDevicePositionFront];
    self.videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    self.videoCamera.horizontallyMirrorFrontFacingCamera = YES;
    
    
    self.stickerFilter = [TPStickerFilter new];
    self.stickerFilter.renderDelegate = self;

    
    self.filterView = [[GPUImageView alloc] initWithFrame:self.view.bounds];
    self.filterView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
    self.filterView.center = self.view.center;

    [self.view insertSubview:self.filterView belowSubview:self.HUDView];
    
    self.landmarkFilter = [[TPLandmarkFilter alloc] init];
    self.landmarkFilter.renderDelegate = self;
    self.landmarkFilter.debugMode = self.debugMode;
    
    self.beautifyFilter = [[TPBeautifyFilter alloc] init];
    
    //when you need realtime data to push stream or something...
    GPUImageRawDataOutput *rawOutput = [[GPUImageRawDataOutput alloc] init];
    rawOutput.newFrameAvailableBlock = ^{
        //GLUbyte* thisIsRawBytes = [rawOutput rawBytesForImage];
    };
    
    /*
        processing chain:
        Camera --> Beautify --> Landmark --> Sticker --> Preview
                                                    |
                                                     --> PixelBuffer
     */
    [self.videoCamera addTarget: self.beautifyFilter];
    [self.beautifyFilter addTarget: self.landmarkFilter];
    [self.landmarkFilter addTarget: self.stickerFilter];
    [self.stickerFilter addTarget: self.filterView];
    [self.stickerFilter addTarget:rawOutput];
    
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    tapRecognizer.numberOfTapsRequired = 2;
    [self.HUDView addGestureRecognizer:tapRecognizer];
    
    [self.close addTarget:self action:@selector(handleClose:) forControlEvents:UIControlEventTouchUpInside];
    
    [TPStickersManager loadStickersWithCompletion:^(NSArray<TPSticker *> *stickers) {
        self.stickers = stickers;
        self.stickerFilter.sticker = [stickers firstObject];
    }];
    
    [self.videoCamera startCameraCapture];
}

- (void)handleClose:(id)sender {
    [self.videoCamera stopCameraCapture];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) handleTap:(id)sender {
    self.landmarkFilter.debugMode = !self.landmarkFilter.debugMode;
}

#pragma mark - TPRenderDelegate

- (void)TPRenderer:(GPUImageOutput *)renderer WillBeginRender:(GPUImageFramebuffer *)buffer {
    if (renderer == self.landmarkFilter) {
        [buffer lock];
        CVPixelBufferRef pixelBuffer = buffer.pixelBuffer;
        CFRetain(pixelBuffer);
        CMFormatDescriptionRef outputFormatDescription = NULL;
        CMVideoFormatDescriptionCreateForImageBuffer(kCFAllocatorDefault, pixelBuffer, &outputFormatDescription);
        
        [_tupu getLandmark:pixelBuffer smoothEnable:self.smoothEnabled];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.debugInfoView.text = _tupu.debugInfo;
            [self.debugImageView setImage:_tupu.debugImage];
        });

        if (_tupu.isFace) {
            self.stickerFilter.faces = @[_tupu.points];
            
            //for debug purpose
            self.landmarkFilter.faces = _tupu.points;
            self.landmarkFilter.rect = _tupu.rect;
        } else {
            self.stickerFilter.faces = @[];
            self.landmarkFilter.faces = @[];
            self.landmarkFilter.rect = CGRectNull;
        }
        CFRelease(pixelBuffer);
        [buffer unlock];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
