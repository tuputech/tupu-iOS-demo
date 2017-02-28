//
//  OptionTableViewController.m
//  TUPUFaceDemo
//
//  Created by drakeDan on 07/02/2017.
//  Copyright © 2017 tupu. All rights reserved.
//

#import "OptionTableViewController.h"
#import "SwitchCell.h"
#import "StepperCell.h"
#import "ViewController.h"

@interface OptionTableViewController (){
    NSMutableArray *_tableConfig;
    
    float _boxScale;
    BOOL _debugMode;
    BOOL _smooth;
}

@end

@implementation OptionTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _boxScale = 0.32f;
    _debugMode = NO;
    _smooth = YES;
    
    _tableConfig = [NSMutableArray arrayWithArray:@[
                                                    //sections...
                                                    @[
                                                        //cells...
                                                        @{
                                                            TP_CELL_ID:     TP_CELL_ID_SWITCH,
                                                            TP_CELL_TITLE:  @"Smooth",
                                                            TP_CELL_SWITCH: @(_smooth),
                                                            TP_CELL_SWITCH_CB: (^(id sender){
                                                                _smooth = ((SwitchCell *)sender).toggle.on;
                                                            })
                                                         },
                                                        @{
                                                            TP_CELL_ID:     TP_CELL_ID_SWITCH,
                                                            TP_CELL_TITLE:  @"Debug Mode",
                                                            TP_CELL_SWITCH: @(_debugMode),
                                                            TP_CELL_SWITCH_CB:(^(id sender) {
                                                                _debugMode = ((SwitchCell *)sender).toggle.on;
                                                            })
                                                         },
                                                        @{
                                                            TP_CELL_ID:     TP_CELL_ID_STEPPER,
                                                            TP_CELL_TITLE:  @"BoxScale",
                                                            TP_CELL_STEP: @(_boxScale),
                                                            TP_CELL_STEPPER_CB:(^(id sender){
                                                                _boxScale = ((StepperCell *)sender).stepper.value;
//                                                                TPLog(@"%f", _boxScale);
                                                            })
                                                         }
                                                     ],
                                                    @[
                                                        @{
                                                            TP_CELL_ID: TP_CELL_ID_START
                                                         }
                                                     ]
                                                   ]];
    
    
    // Uncomment the following line to preserve selection between presentations.
     self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _tableConfig.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return ((NSArray *)_tableConfig[section]).count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *data = _tableConfig[indexPath.section][indexPath.row];

    UITableViewCell<TPCellConfig> *cell = [tableView dequeueReusableCellWithIdentifier:data[TP_CELL_ID] forIndexPath:indexPath];
    if ([cell conformsToProtocol:@protocol(TPCellConfig)]) {
        [cell configCell:data];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([[((NSDictionary *)_tableConfig[indexPath.section][indexPath.row]) objectForKey:TP_CELL_ID]  isEqual: TP_CELL_ID_START]) {
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    ViewController *cv = segue.destinationViewController;
    cv.debugMode = _debugMode;
    cv.boxScale = _boxScale;
    cv.smoothEnabled = _smooth;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
