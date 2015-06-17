//
//  FixInfoViewController.h
//  HaoCLZ
//
//  Created by Loading on 15/6/16.
//  Copyright (c) 2015年 liuhj. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FixInfoViewController : UIViewController
- (IBAction)done:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *nickname;
@property (weak, nonatomic) IBOutlet UITextField *phone;
@property (weak, nonatomic) IBOutlet UITextField *address;

@end
