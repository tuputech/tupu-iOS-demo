//
//  SwitchCell.m
//  TUPUFaceDemo
//
//  Created by drakeDan on 07/02/2017.
//  Copyright © 2017 tupu. All rights reserved.
//

#import "SwitchCell.h"

@implementation SwitchCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark TPCellConfig protocol
- (void) configCell:(NSDictionary*)data {
    self.title.text = data[TP_CELL_TITLE];
    self.toggle.on = [((NSNumber *)data[TP_CELL_SWITCH]) boolValue];
    self.valueChange = data[TP_CELL_SWITCH_CB];
    
    [self.toggle addTarget:self action:@selector(didToggle:) forControlEvents:UIControlEventValueChanged];
}

- (void) didToggle:(id)sender {
    self.valueChange(self);
}

//- (void) setValueChangeCallback:(TPOptionValueChangeCallback)callback {
//    
//}

@end
