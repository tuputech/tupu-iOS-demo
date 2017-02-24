//
//  GPUImageFramebuffer+PixelBuffer.h
//  tuputechSDK
//
//  Created by bug小英雄 on 2017/2/23.
//  Copyright © 2017年 TupuTech. All rights reserved.
//

#import <GPUImage/GPUImageFramework.h>
#import <Foundation/Foundation.h>

@interface GPUImageFramebuffer(PixelBuffer)
- (CVPixelBufferRef)pixelBuffer;
@end
