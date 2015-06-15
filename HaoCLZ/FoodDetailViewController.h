//
//  FoodDetailViewController.h
//  HaoCLZ
//
//  Created by Loading on 15/6/13.
//  Copyright (c) 2015年 liuhj. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FoodDetailViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *foodImageView;
@property (weak, nonatomic) IBOutlet UILabel *foodName_label;
@property (weak, nonatomic) IBOutlet UILabel *foodPrice_label;

@property (strong, nonatomic) NSString *food_name;
@property (strong, nonatomic) UIImage *food_image;
@property (strong, nonatomic) NSString *food_price;
@property (strong, nonatomic) NSString *title;
@end
