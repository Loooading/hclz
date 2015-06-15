//
//  OrderListTableViewCell.h
//  HaoCLZ
//
//  Created by Loading on 15/6/14.
//  Copyright (c) 2015年 liuhj. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OrderListTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *shop_logo_imgaeVIew;
@property (weak, nonatomic) IBOutlet UILabel *state_label;
@property (weak, nonatomic) IBOutlet UILabel *date_label;
@property (weak, nonatomic) IBOutlet UILabel *shop_name_logo;
@property (weak, nonatomic) IBOutlet UILabel *foodAmount_label;

@end
