//
//  StickerCollectionViewCell.m
//  TUPUFaceDemo
//
//  Created by 候 金鑫 on 2017/2/8.
//  Copyright © 2017年 tupu. All rights reserved.
//

#import "StickerCollectionViewCell.h"

@interface StickerCollectionViewCell ()
@property (weak, nonatomic) IBOutlet UIImageView *stickerPreivewImg;

@end

@implementation StickerCollectionViewCell
- (void)awakeFromNib {
    [super awakeFromNib];
    [_stickerPreivewImg setImage: [UIImage imageNamed:@"sticker_preivew"]];
}

- (void)setSelected:(BOOL)selected {
    if (selected) {
        self.layer.borderWidth = 2;
        self.layer.borderColor = [UIColor greenColor].CGColor;
    }
    else {
        self.layer.borderWidth = 0;
    }
}

@end
