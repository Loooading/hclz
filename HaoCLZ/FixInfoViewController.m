//
//  FixInfoViewController.m
//  HaoCLZ
//
//  Created by Loading on 15/6/16.
//  Copyright (c) 2015年 liuhj. All rights reserved.
//

#import "FixInfoViewController.h"

@interface FixInfoViewController ()

@end

@implementation FixInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)done:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        NSLog(@"fixinfo view done");
        NSMutableDictionary *theData = [[NSMutableDictionary alloc] init];
        if (![self.nickname.text isEqualToString:@""]) {
            [theData setValue:self.nickname.text forKey:@"nickname"];
        }
        if (![self.phone.text isEqualToString:@""]) {
            [theData setValue:self.phone.text forKey:@"phone"];

        }
        if (![self.address.text isEqualToString:@""]) {
            [theData setValue:self.address.text forKey:@"address"];
        }
        [theData setValue:self.address.text forKey:@"address"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"FixCompletionNontification" object:nil userInfo:theData];

    }];
}
@end
