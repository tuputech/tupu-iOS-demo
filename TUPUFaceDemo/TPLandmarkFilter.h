//
//  TPLandmarkFilter.h
//  TUPUFaceDemo
//
//  Created by drakeDan on 11/01/2017.
//  Copyright © 2017 tupu. All rights reserved.
//

#import <GPUImage/GPUImageFramework.h>
#import "TPRenderingProtocol.h"

@interface TPLandmarkFilter : GPUImageFilter

@property (nonatomic, weak) id<TPRenderingDelegate> renderDelegate;

@property (nonatomic, strong) NSArray<NSValue*>* faces;

@property (nonatomic, assign) CGRect rect;

@end
