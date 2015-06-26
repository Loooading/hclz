//
//  UserManageViewController.h
//  HaoCLZ
//
//  Created by Loading on 15/6/13.
//  Copyright (c) 2015年 liuhj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "CustomViewController.h"
#import "GlobalDefine.h"


@interface UserManageViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *nickname_label;
@property (weak, nonatomic) IBOutlet UILabel *address_label;
- (IBAction)logout:(id)sender;

@end
