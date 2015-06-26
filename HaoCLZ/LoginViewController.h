//
//  LoginViewController.h
//  HaoCLZ
//
//  Created by Loading on 15/6/12.
//  Copyright (c) 2015年 liuhj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomViewController.h"
#import "AppDelegate.h"
//#import "NearByViewController.h"
#import "GlobalDefine.h"


@interface LoginViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *username_textField;
@property (weak, nonatomic) IBOutlet UITextField *password_textFiled;
- (IBAction)login:(id)sender;

@end
