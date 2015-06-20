//
//  OrderDetailViewController.h
//  HaoCLZ
//
//  Created by Loading on 15/6/14.
//  Copyright (c) 2015年 liuhj. All rights reserved.
//

#import "CustomViewController.h"

@interface OrderDetailViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *orderState_label;
@property (weak, nonatomic) IBOutlet UILabel *date_label;
@property (weak, nonatomic) IBOutlet UILabel *date1_label;
@property (weak, nonatomic) IBOutlet UIImageView *shop_image;
@property (weak, nonatomic) IBOutlet UILabel *shop_name_label;
@property (weak, nonatomic) IBOutlet UILabel *foodAmount_label;
@property (weak, nonatomic) IBOutlet UILabel *shop_phone_label;
@property (weak, nonatomic) IBOutlet UILabel *order_id_label;
@property (weak, nonatomic) IBOutlet UILabel *lianxiren_label;
@property (weak, nonatomic) IBOutlet UILabel *service_address_label;
@property (weak, nonatomic) IBOutlet UILabel *phone_label;
@property (weak, nonatomic) IBOutlet UIButton *confirm_button;
@property (weak, nonatomic) IBOutlet UIButton *delete_button;
- (IBAction)comfirm:(id)sender;
- (IBAction)deleOrder:(id)sender;

@property (strong, nonatomic) NSMutableDictionary *orderDetailInfo;
@property (nonatomic) NSInteger orderRequestType;


@end
