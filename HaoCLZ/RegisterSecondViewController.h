//
//  RegisterSecondViewController.h
//  HaoCLZ
//
//  Created by Loading on 15/6/13.
//  Copyright (c) 2015年 liuhj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomViewController.h"
#import "NearByViewController.h"
#import "GlobalDefine.h"


@interface RegisterSecondViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *nickname_textfield;
@property (weak, nonatomic) IBOutlet UITextField *mobile_textfield;
@property (weak, nonatomic) IBOutlet UITextField *email_textfield;
- (IBAction)register:(id)sender;

@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSString *password;
@end
