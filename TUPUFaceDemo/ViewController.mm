//
//  ViewController.m
//  TUPUFaceDemo
//
//  Created by drakeDan on 10/01/2017.
//  Copyright © 2017 tupu. All rights reserved.
//

#import "ViewController.h"
#import "SKSticker.h"
#import "SKStickerFilter.h"
#import <GPUImage/GPUImageFramework.h>
#import <tupu-sdk/TUPULandmark.h>
#import <opencv2/opencv.hpp>
#import <opencv2/highgui/ios.h>
#import "TPFrameProcessingProtocol.h"
#import "TPLandmarkFilter.h"

@interface ViewController ()<GPUImageVideoCameraDelegate, TPFrameProcessingDelegate>
@property (nonatomic, strong) GPUImageVideoCamera *videoCamera;
@property (nonatomic, strong) GPUImageView *filterView;

@property (nonatomic, strong) SKStickerFilter *stickerFilter;
@property (nonatomic, copy) NSArray<SKSticker *> *stickers;

@property (nonatomic, strong) TPLandmarkFilter *landmarkFilter;
@end

@implementation ViewController{
    TUPULandmark *_tupu;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _tupu = [TUPULandmark new];
    _tupu.boxScale = 0.23;
    if (![_tupu initWithModel:@"tupu_face_1_0_0.model"]) {
        NSLog(@"Failed to initialize model");
        return;
    }
    
    self.videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:AVCaptureDevicePositionFront];
    self.videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    self.videoCamera.horizontallyMirrorFrontFacingCamera = YES;
    self.videoCamera.delegate = self;
    
    self.stickerFilter = [SKStickerFilter new];

    
    self.filterView = [[GPUImageView alloc] initWithFrame:self.view.bounds];
    self.filterView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
    self.filterView.center = self.view.center;
    [self.view addSubview:self.filterView];
    
    self.landmarkFilter = [[TPLandmarkFilter alloc] init];
    self.landmarkFilter.frameDelegate = self;
    
    
    [self.videoCamera addTarget:self.landmarkFilter];
    [self.landmarkFilter addTarget:self.stickerFilter];
    [self.stickerFilter addTarget:self.filterView];
    
    
    [SKStickersManager loadStickersWithCompletion:^(NSArray<SKSticker *> *stickers) {
        self.stickers = stickers;
        self.stickerFilter.sticker = [stickers firstObject];
    }];
    
    [self.videoCamera startCameraCapture];
}

#pragma mark - GPUImageVideoCameraDelegate
- (void)willOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer{
    CMFormatDescriptionRef outputFormatDescription = NULL;
    CMVideoFormatDescriptionCreateForImageBuffer(kCFAllocatorDefault, CMSampleBufferGetImageBuffer(sampleBuffer), &outputFormatDescription);
    
}

- (void)willProcessFrame:(GPUImageFramebuffer *)buffer {
    [buffer lock];
    [buffer lockForReading];
    CVPixelBufferRef pixelBuffer = buffer.pixelBuffer;
    CFRetain(pixelBuffer);
    CMFormatDescriptionRef outputFormatDescription = NULL;
    CMVideoFormatDescriptionCreateForImageBuffer(kCFAllocatorDefault, pixelBuffer, &outputFormatDescription);
    
    char a[100];
    UIImage *img = [_tupu getLandmarkFromPixelBuffer:pixelBuffer info:a faceness:0.6f smoothEnable:YES];

    if (_tupu.isFace) {
        self.stickerFilter.faces = @[_tupu.points];
        self.landmarkFilter.faces = _tupu.points;
        self.landmarkFilter.rect = _tupu.rect;
    } else {
        self.stickerFilter.faces = @[];
        self.landmarkFilter.faces = @[];
        self.landmarkFilter.rect = CGRectNull;
    }
    CFRelease(pixelBuffer);
    [buffer unlockAfterReading];
    [buffer unlock];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
