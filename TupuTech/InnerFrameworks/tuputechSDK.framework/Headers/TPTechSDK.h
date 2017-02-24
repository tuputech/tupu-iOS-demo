//
//  TPTechSDK.h
//  tuputechSDK
//
//  Created by 候 金鑫 on 2017/2/13.
//  Copyright © 2017年 候 金鑫. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TPServiceInterfaces.h"
#import "GPUImageFramebuffer+PixelBuffer.h"

@interface TPTechSDK : NSObject
+ (id<TPSDKAuthInterface>)createTPAuthService;
+ (void)createService:(TPServiceType)type complete:(TuPuServiceResultBlock)block;
@end
