//
//  TPServiceInterfaces.h
//  tuputechSDK
//
//  Created by 候 金鑫 on 2017/2/13.
//  Copyright © 2017年 候 金鑫. All rights reserved.
//

#import <CoreGraphics/CoreGraphics.h>
#import <CoreVideo/CoreVideo.h>
#import <UIKit/UIKit.h>

#ifndef TPServiceInterfaces_h
#define TPServiceInterfaces_h

//@class UIImage;
@class TPBeautifyFilter;
@class TPLandmarkFilter;
@class TPStickerFilter;
@class GPUImageOutput;
@class GPUImageFramebuffer;
@class GPUImageFilterGroup;
@class GPUImageFilter;

typedef void (^TuPuBooleanResultBlock)(BOOL succeeded, NSError *error);
typedef void (^TuPuIntegerResultBlock)(NSInteger number, NSError *error);
typedef void (^TuPuArrayResultBlock)(NSArray *objects, NSError *error);
//typedef void (^TuPuConversationResultBlock)(AVIMConversation *conversation, NSError *error);
typedef void (^TuPuProgressBlock)(NSInteger percentDone);
typedef void (^TuPuServiceResultBlock)(id service, NSError *error);


//struct TuPuFaceCheckResult {
//    NSArray <NSValue*>*points;
//    CGRect rect;
//};

typedef void (^TuPuFaceCheckResultBlock)(NSError *error, BOOL isFace, NSArray<NSValue*>*keyPoints, CGRect rect);
typedef void (^TuPuFaceCheckDebugInfo)(NSString *debugInfo, UIImage *debugImg);

typedef void(^TuPuAuthServiceResultBlock)(BOOL isValid, NSError *err);

typedef NS_ENUM(NSInteger, TPLicenseDuration) {
    TPLicenseDuration30Days = 30,
    TPLicenseDuration365Days = 365
};

typedef NS_ENUM(NSInteger, TPServiceType) {
    TPAuthService           = 0x7e1,
    TPFaceCheckService      = 0x7e2,
    TPRenderingService         = 0x7e3,
    TPRenderFaceThinService = 0x7e4,
};


@protocol TPServiceInterfaceBase
@required
/**该TPservice是否需要鉴权*/
- (BOOL)isAuthable:(BOOL)usrIsTupuTech;

/** 获取吊销时间*/
- (NSDate *)getExpiration;

/** 获取api 名用于联网授权*/
- (NSInteger)getAPIId;

/** 是否开启debug模式*/
- (void)enableDebugMode:(BOOL)enable;


@optional
/** 获取版本号 */
- (NSString *)getVersion;

/**传递自定义参数启动service*/
- (void)bootupService:(NSDictionary*)params complete:(TuPuBooleanResultBlock)block;

@end

@protocol TPSDKAuthInterface <TPServiceInterfaceBase>
- (void)authServiceByType:(TPServiceType)type complete:(TuPuAuthServiceResultBlock)block;
- (NSString*)authMsgWithDuration:(TPLicenseDuration)duration APIs:(NSArray <NSNumber*> *)apis;
- (BOOL)setLicense:(NSString *)licenseString APIs:(NSArray<NSNumber *> *)apis;
- (void)autoInstallLicenseBySDKWithAppkey:(NSString*)appkey appSecret:(NSString*)secret serviceIDs:(NSArray<NSNumber*>*)ids complete:(TuPuBooleanResultBlock)block;

@end

@protocol TPRenderingDelegate <NSObject>
@optional
- (void)TPRenderer:(GPUImageOutput *)renderer WillBeginRender:(GPUImageFramebuffer *)buffer;
- (void)TPRenderer:(GPUImageOutput *)renderer DidFinishRender:(GPUImageFramebuffer *)buffer;
@end

@protocol TPStickerDelegate <NSObject>
- (void)willProcessFrame:(GPUImageFramebuffer *)buffer;
@end

@protocol TPLandmarkServiceInterface <TPServiceInterfaceBase>

- (void)setFaceRectDebugScale:(float)scale;
- (void)faceCheckAndLandmark:(CVPixelBufferRef)pixelBuffer smoothEnable:(BOOL)enable complete:(TuPuFaceCheckResultBlock)block debug:(TuPuFaceCheckDebugInfo)debugBlock;

@end



@protocol TPStickerInfo <NSObject>
- (NSString*)stickerThumb;
@end

typedef void(^TuPuRenderLoadStickerResult)(NSArray<id<TPStickerInfo>> *result, NSError *err);

@protocol TPReceiveFaceKeyPointProtocol <NSObject>

- (void)updateFaceKeyPoint:(NSArray<NSValue*> *)szKeyPoints;
- (void)updateFaceRect:(CGRect)rect;

@end

@protocol TPSetRenderEventDelegateProtocol <NSObject>

- (void)setReceiveRenderEventDelegate:(id<TPRenderingDelegate>)delegate;

@end

@protocol TPRenderServiceInterface <TPServiceInterfaceBase>
- (GPUImageFilterGroup*)createTPBeautifyFilter;
- (GPUImageFilter<TPReceiveFaceKeyPointProtocol,TPSetRenderEventDelegateProtocol>*)createTPLandmarkFilter;
- (GPUImageFilter<TPReceiveFaceKeyPointProtocol>*)createStickerFilter;
//- (void)setDelegateForFilter:(GPUImageOutput*)targetFilter delegate:(id<TPRenderingDelegate>)delegate;
- (void)loadStickerWithPath:(NSString*)path complete:(TuPuRenderLoadStickerResult)block;
- (void)renderStickerWithIndex:(NSInteger)index;
@end

#endif /* TPServiceInterfaces_h */
