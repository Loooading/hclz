//
//  UserManageViewController.m
//  HaoCLZ
//
//  Created by Loading on 15/6/13.
//  Copyright (c) 2015年 liuhj. All rights reserved.
//

#import "UserManageViewController.h"

@interface UserManageViewController () <BMKGeoCodeSearchDelegate>
{
    BMKGeoCodeSearch *_searcher;
}
@end

@implementation UserManageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    AppDelegate *myDelegate = [[UIApplication sharedApplication] delegate];
    self.nickname_label.text = myDelegate.nickname;
    //初始化地理编码检索
    _searcher =[[BMKGeoCodeSearch alloc]init];
    _searcher.delegate = self;
    //发起反向地理编码检索
    CLLocationCoordinate2D pt = (CLLocationCoordinate2D){myDelegate.latitude, myDelegate.longitude};
    //    CLLocationCoordinate2D pt = (CLLocationCoordinate2D){39.915, 116.404};
    
    BMKReverseGeoCodeOption *reverseGeoCodeSearchOption = [[BMKReverseGeoCodeOption alloc]init];
    reverseGeoCodeSearchOption.reverseGeoPoint = pt;
    BOOL flag = [_searcher reverseGeoCode:reverseGeoCodeSearchOption];
    //    [reverseGeoCodeSearchOption release];
    if(flag)
    {
        NSLog(@"反geo检索发送成功");
    }
    else
    {
        NSLog(@"反geo检索发送失败");
    }
}

//接收反向地理编码结果
-(void) onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:
(BMKReverseGeoCodeResult *)result
                        errorCode:(BMKSearchErrorCode)error{
    if (error == BMK_SEARCH_NO_ERROR) {
        //在此处理正常结果
        NSLog(@"%@", result.address);
        self.address_label.text = result.address;
    }
    else {
        NSLog(@"抱歉，未找到结果");
    }
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

- (IBAction)logout:(id)sender {
    [CustomViewController showMessage:@"已退出登录!"];
    AppDelegate *myDelegate = [[UIApplication sharedApplication] delegate];
    myDelegate.uid = nil;
    myDelegate.nickname = nil;
    myDelegate.phone = nil;
    myDelegate.password = nil;
    [self performSegueWithIdentifier:@"goToNearby" sender:nil];
    //退出登录,清除所有userdefault数据
//    [NSUserDefaults resetStandardUserDefaults];
    NSDictionary *defaultsDictionary = [[NSUserDefaults standardUserDefaults]dictionaryRepresentation];
    for (NSString *key in [defaultsDictionary allKeys]) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];

}
@end
