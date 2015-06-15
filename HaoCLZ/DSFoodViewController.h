//
//  DSFoodViewController.h
//  HaoCLZ
//
//  Created by Loading on 15/6/15.
//  Copyright (c) 2015年 liuhj. All rights reserved.
//

#import "CustomViewController.h"

@interface DSFoodViewController : CustomViewController
@property (weak, nonatomic) IBOutlet UITableView *foodListTableView;
@property (weak, nonatomic) IBOutlet UILabel *foodNumber;
@property (weak, nonatomic) IBOutlet UILabel *totalPrice;
- (IBAction)goToNextStep:(id)sender;
@end
