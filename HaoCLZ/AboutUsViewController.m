//
//  AboutUsViewController.m
//  HaoCLZ
//
//  Created by Loading on 15/6/25.
//  Copyright (c) 2015年 liuhj. All rights reserved.
//

#import "AboutUsViewController.h"

@interface AboutUsViewController ()

@end

@implementation AboutUsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self addMenuButton];
    self.context.numberOfLines = 0;
    //设置label顶端对齐
    [self.context sizeToFit];
    [self.scrollView setContentSize:CGSizeMake(320, 600)];

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

@end
