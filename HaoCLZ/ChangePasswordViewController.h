//
//  ChangePasswordViewController.h
//  HaoCLZ
//
//  Created by Loading on 15/6/13.
//  Copyright (c) 2015年 liuhj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "CustomViewController.h"
#import "GlobalDefine.h"


@interface ChangePasswordViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *newpass_label;
@property (weak, nonatomic) IBOutlet UITextField *newpasscheck_label;
- (IBAction)changePass:(id)sender;

@end
