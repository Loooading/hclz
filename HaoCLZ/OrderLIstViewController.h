//
//  OrderLIstViewController.h
//  HaoCLZ
//
//  Created by Loading on 15/6/14.
//  Copyright (c) 2015年 liuhj. All rights reserved.
//

#import "CustomViewController.h"
#import "OrderListTableViewCell.h"

@interface OrderLIstViewController : CustomViewController
@property (weak, nonatomic) IBOutlet UITableView *orderListTableView;
@property (nonatomic) NSInteger orderRequestType;

@end
