//
//  BalanceViewController.h
//  HaoCLZ
//
//  Created by Loading on 15/6/11.
//  Copyright (c) 2015年 liuhj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BaiduMapAPI/BMapKit.h>
#import "AppDelegate.h"
#import "CustomViewController.h"

@interface BalanceViewController : UIViewController
@property (strong, nonatomic) NSString *shop_id;
@property (strong, nonatomic) NSString *shop_logo;
@property (strong, nonatomic) NSString *shop_phone;
@property (strong, nonatomic) NSString *shop_name;
@property (strong, nonatomic) NSString *food_price;
@property (strong, nonatomic) NSString *foodAmount;
@property (strong, nonatomic) NSString *total_price;
@property (strong, nonatomic) NSString *deliver_charge;


@property (weak, nonatomic) IBOutlet UILabel *total_price_label;
@property (weak, nonatomic) IBOutlet UILabel *food_price_label;
@property (weak, nonatomic) IBOutlet UILabel *deliver_charge_label;
@property (weak, nonatomic) IBOutlet UILabel *nick_name_label;
@property (weak, nonatomic) IBOutlet UILabel *phone_label;
@property (weak, nonatomic) IBOutlet UILabel *service_address_label;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (nonatomic) NSUInteger *foodRequestType;

- (IBAction)commitOrder:(id)sender;

@end
