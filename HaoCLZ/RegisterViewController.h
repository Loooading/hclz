//
//  RegisterViewController.h
//  HaoCLZ
//
//  Created by Loading on 15/6/12.
//  Copyright (c) 2015年 liuhj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomViewController.h"
#import "RegisterSecondViewController.h"

@interface RegisterViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *userName_textField;
@property (weak, nonatomic) IBOutlet UITextField *password_textField;
@property (weak, nonatomic) IBOutlet UITextField *checkPassword_textField;
@property (weak, nonatomic) IBOutlet UITextField *validateCode_textField;
@property (weak, nonatomic) IBOutlet UILabel *generatedCode_label;
- (IBAction)refreshValidateCode:(id)sender;
- (IBAction)registerDetermin:(id)sender;

@property (strong, nonatomic)NSString *validateCode;

@end
