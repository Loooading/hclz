//
//  ShopCarViewController.h
//  HaoCLZ
//
//  Created by Loading on 15/6/11.
//  Copyright (c) 2015年 liuhj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShopCarTableViewCell.h"
#import "BalanceViewController.h"
#import "AppDelegate.h"

@interface ShopCarViewController : UIViewController
@property (nonatomic) float totalPrice;
@property (nonatomic) NSUInteger foodNumber;
@property (weak, nonatomic) IBOutlet UITableView *shopCarInfoTableView;
@property (weak, nonatomic) IBOutlet UILabel *foodNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalPriceLaber;
@property (strong, nonatomic) NSMutableArray *shopCarInfo;
@property (strong, nonatomic) NSString *shop_id;
@property (strong, nonatomic) NSString *shop_logo;
@property (strong, nonatomic) NSString *shop_phone;
@property (strong, nonatomic) NSString *shop_name;
@property (strong, nonatomic) NSString *deliver_charge;
@property (nonatomic) NSUInteger *foodRequestType;
@end
