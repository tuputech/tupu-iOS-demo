//
//  StepperCell.m
//  TUPUFaceDemo
//
//  Created by drakeDan on 07/02/2017.
//  Copyright © 2017 tupu. All rights reserved.
//

#import "StepperCell.h"

@implementation StepperCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark TPCellConfig protocol
- (void) configCell:(NSDictionary *)data {
    self.title.text = data[TP_CELL_TITLE];
    self.stepper.value = [((NSNumber *)data[TP_CELL_STEP]) doubleValue];
    self.read.text = [NSString stringWithFormat:@"%.0f%%", self.stepper.value * 100];
    self.valueChange = data[TP_CELL_STEPPER_CB];
    
    [self.stepper addTarget:self action:@selector(stepChange:) forControlEvents:UIControlEventValueChanged];
}

- (void) stepChange:(id)sender {
    self.read.text = [NSString stringWithFormat:@"%.0f%%", self.stepper.value * 100];
    self.valueChange(self);
}
@end
