//
//  FoodViewController.h
//  HaoCLZ
//
//  Created by Loading on 15/6/10.
//  Copyright (c) 2015年 liuhj. All rights reserved.
//

#import "CustomViewController.h"
#import "FoodTableViewCell.h"
#import "ShopCarViewController.h"
#import "FoodDetailViewController.h"
#import "AppDelegate.h"

@interface FoodViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITableView *foodListTableView;
@property (weak, nonatomic) IBOutlet UILabel *foodNumber;
@property (weak, nonatomic) IBOutlet UILabel *totalPrice;

@property (strong, nonatomic) NSString *deliver_charge;
@property (strong, nonatomic) NSString *shop_id;
@property (strong, nonatomic) NSString *shop_logo;
@property (strong, nonatomic) NSString *shop_phone;
@property (strong, nonatomic) NSString *shop_name;
//- (IBAction)goToShopCarBalance:(id)sender;
- (IBAction)goToNextStep:(id)sender;

@end
