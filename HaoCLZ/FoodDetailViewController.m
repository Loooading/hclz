//
//  FoodDetailViewController.m
//  HaoCLZ
//
//  Created by Loading on 15/6/13.
//  Copyright (c) 2015年 liuhj. All rights reserved.
//

#import "FoodDetailViewController.h"

@interface FoodDetailViewController ()

@end

@implementation FoodDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    self.introduceLabel.numberOfLines = 0;
//    [self.introduceLabel sizeToFit];
    [self.navigationController setNavigationBarHidden:NO];
    self.foodImageView.image = self.food_image;
    self.foodName_label.text = self.food_name;
    self.foodPrice_label.text = self.food_price;
    self.introduceLabel.text = self.intrduce;
    self.navigationController.title = self.title;
//    self.introduceLabel.numberOfLines = 0;
//    [self.introduceLabel sizeToFit];
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
