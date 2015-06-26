//
//  ShopCarTableViewCell.h
//  HaoCLZ
//
//  Created by Loading on 15/6/11.
//  Copyright (c) 2015年 liuhj. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShopCarTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *food_name;
@property (weak, nonatomic) IBOutlet UILabel *foodNumber;
@property (weak, nonatomic) IBOutlet UILabel *foodPrice;
@property (weak, nonatomic) IBOutlet UIButton *addButton;
@property (weak, nonatomic) IBOutlet UIButton *minusButton;

@end
