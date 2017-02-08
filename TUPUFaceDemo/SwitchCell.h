//
//  SwitchCell.h
//  TUPUFaceDemo
//
//  Created by drakeDan on 07/02/2017.
//  Copyright © 2017 tupu. All rights reserved.
//

#import <UIKit/UIKit.h>

/* cell config key */
#define TP_CELL_ID      @"id"
#define TP_CELL_TITLE   @"title"
#define TP_CELL_SWITCH  @"enable"
#define TP_CELL_READ    @"read"
#define TP_CELL_STEP    @"step"

#define TP_CELL_SWITCH_CB @"switch_cb"
#define TP_CELL_STEPPER_CB @"stepper_cb"

/* cell identifyier */
#define TP_CELL_ID_SWITCH @"SwitchCell"
#define TP_CELL_ID_STEPPER @"StepperCell"
#define TP_CELL_ID_START   @"StartButton"

typedef void(^TPOptionValueChangeCallback)(id sender);

@protocol TPCellConfig

- (void) configCell:(NSDictionary *)data;

//- (void) setValueChangeCallback:(TPOptionValueChangeCallback)callback;

@end

@interface SwitchCell : UITableViewCell<TPCellConfig>

@property (copy, nonatomic) TPOptionValueChangeCallback valueChange;

@property (weak, nonatomic) IBOutlet UILabel *title;

@property (weak, nonatomic) IBOutlet UISwitch *toggle;

@end
