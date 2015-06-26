//
//  FoodTableViewCell.h
//  HaoCLZ
//
//  Created by Loading on 15/6/10.
//  Copyright (c) 2015年 liuhj. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FoodTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *food_pic;
@property (weak, nonatomic) IBOutlet UILabel *food_name;
@property (weak, nonatomic) IBOutlet UIButton *buttonPrice;
@property (weak, nonatomic) IBOutlet UIButton *minusButton;
@property (weak, nonatomic) IBOutlet UILabel *number;
@property (weak, nonatomic) IBOutlet UILabel *introduceLabel;

@end
