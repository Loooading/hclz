//
//  NearByTableViewCell.h
//  HaoCLZ
//
//  Created by Loading on 15/6/10.
//  Copyright (c) 2015年 liuhj. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NearByTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *shop_logo;
@property (weak, nonatomic) IBOutlet UILabel *shop_name;
@property (weak, nonatomic) IBOutlet UIImageView *starsImage;
@property (weak, nonatomic) IBOutlet UILabel *stars;
@property (weak, nonatomic) IBOutlet UILabel *others;
@property (weak, nonatomic) IBOutlet UILabel *introduce;
@property (weak, nonatomic) IBOutlet UIButton *delCollectionButton;

@end
