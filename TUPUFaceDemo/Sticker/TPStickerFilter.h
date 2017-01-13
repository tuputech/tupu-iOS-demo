//
//  TPStickerFilter.h
//  CameraStickerDemo
//
//  Created by Sinkup on 2016/12/4.
//  Copyright © 2016年 Asura. All rights reserved.
//

#import <GPUImage/GPUImageFramework.h>


@class TPSticker;

@protocol TPStickerDelegate <NSObject>

- (void)willProcessFrame:(GPUImageFramebuffer *)buffer;

@end

@interface TPStickerFilter : GPUImageFilter

/**
 需要绘制的贴纸
 */
@property (nonatomic, strong) TPSticker *sticker;

@property (nonatomic, strong) id<TPStickerDelegate> stickerDelegate;


/**
 关键点，元素需为CGPoint数组
 */
@property (nonatomic, copy) NSArray<NSArray *> *faces;

@end
