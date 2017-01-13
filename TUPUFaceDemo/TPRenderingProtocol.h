//
//  TPFrameProcessingProtocol.h
//  TUPUFaceDemo
//
//  Created by drakeDan on 11/01/2017.
//  Copyright © 2017 tupu. All rights reserved.
//

#ifndef TPFrameProcessingProtocol_h
#define TPFrameProcessingProtocol_h

@protocol TPRenderingDelegate <NSObject>

- (void)TPRendererWillBeginRender:(GPUImageFramebuffer *)buffer;

- (void)TPRendererDidFinishRender:(GPUImageFramebuffer *)buffer;

@end
#endif /* TPFrameProcessingProtocol_h */
