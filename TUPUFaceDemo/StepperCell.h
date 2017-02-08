//
//  StepperCell.h
//  TUPUFaceDemo
//
//  Created by drakeDan on 07/02/2017.
//  Copyright © 2017 tupu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SwitchCell.h"

@interface StepperCell : UITableViewCell<TPCellConfig>

@property (copy, nonatomic) TPOptionValueChangeCallback valueChange;

@property (weak, nonatomic) IBOutlet UILabel *title;

@property (weak, nonatomic) IBOutlet UILabel *read;

@property (weak, nonatomic) IBOutlet UIStepper *stepper;

@end
