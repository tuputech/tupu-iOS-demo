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
@end

@implementation ViewController{
    TUPULandmark *_tupu;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _tupu = [TUPULandmark new];
    _tupu.boxScale = 0.2;
    if (![_tupu initWithModel:@"tupu_face_1_0_0.model"]) {
        NSLog(@"Failed to initialize model");
        return;
    }

    self.videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:AVCaptureDevicePositionFront];
    self.videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    self.videoCamera.horizontallyMirrorFrontFacingCamera = YES;
    
    
    self.stickerFilter = [TPStickerFilter new];
    self.stickerFilter.renderDelegate = self;

    
    self.filterView = [[GPUImageView alloc] initWithFrame:self.view.bounds];
    self.filterView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
    self.filterView.center = self.view.center;
    [self.view addSubview:self.filterView];
    
    self.landmarkFilter = [[TPLandmarkFilter alloc] init];
    self.landmarkFilter.renderDelegate = self;
    self.landmarkFilter.debugMode = NO;
    
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
    [self.filterView addGestureRecognizer:tapRecognizer];
    
    
    [TPStickersManager loadStickersWithCompletion:^(NSArray<TPSticker *> *stickers) {
        self.stickers = stickers;
        self.stickerFilter.sticker = [stickers firstObject];
    }];
    
    [self.videoCamera startCameraCapture];
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
        
        [_tupu getLandmark:pixelBuffer smoothEnable:YES];

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
