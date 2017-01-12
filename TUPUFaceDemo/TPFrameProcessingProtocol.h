//
//  TPFrameProcessingProtocol.h
//  TUPUFaceDemo
//
//  Created by drakeDan on 11/01/2017.
//  Copyright © 2017 tupu. All rights reserved.
//

#ifndef TPFrameProcessingProtocol_h
#define TPFrameProcessingProtocol_h

@protocol TPFrameProcessingDelegate <NSObject>

- (void)willProcessFrame:(GPUImageFramebuffer *)buffer;

@end
#endif /* TPFrameProcessingProtocol_h */
