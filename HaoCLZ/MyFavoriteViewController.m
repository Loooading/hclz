//
//  MyFavoriteViewController.m
//  HaoCLZ
//
//  Created by Loading on 15/6/15.
//  Copyright (c) 2015年 liuhj. All rights reserved.
//

#import "MyFavoriteViewController.h"
#import "NearByTableViewCell.h"
#import "FoodViewController.h"

@interface MyFavoriteViewController ()
{
    NSMutableArray *_shopList;
    NSArray *itemsArray;
}
@end

@implementation MyFavoriteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [super viewDidLoad];
    [self addMenuButton];
    [self requestDataWithType:@"1"];

}

#pragma mark - Request Data

- (void)requestDataWithType:(NSString *)type{
    //type:  0食品  1店铺
    AppDelegate *myDelegate = [[UIApplication sharedApplication] delegate];
    NSString *path = [[NSString alloc] initWithFormat:@"/TakeOut/action/msg_myCollection"];
    NSMutableDictionary *para = [[NSMutableDictionary alloc] init];
    
    [para setValue:type forKey:@"type"];
    [para setValue:myDelegate.uid forKey:@"uid"];
    
        MKNetworkEngine *engine = [[MKNetworkEngine alloc] initWithHostName:@"101.200.179.69:8080" customHeaderFields:nil];
    MKNetworkOperation *op = [engine operationWithPath:path params:para httpMethod:@"GET"];
    [op addCompletionHandler:^(MKNetworkOperation *operation){
        NSLog(@"respons string : %@", [operation responseString]);
        NSData *data = [operation responseData];
        NSDictionary *resDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        _shopList = [resDic valueForKey:@"shop"];
        [self.myFavShopListTableView reloadData];
    }errorHandler:^(MKNetworkOperation *errorOp, NSError *err){
        NSLog(@"请求错误 : %@", [err localizedDescription]);
    }];
    [engine enqueueOperation:op];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _shopList.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifer;
    NearByTableViewCell * cell ;
    cellIdentifer = @"NearByTableViewCell";
    cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifer];
    if(!cell)
    {
        cell = [[NearByTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifer];
    }
    cell.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    NSUInteger row = [indexPath row];
    NSMutableDictionary *shop = _shopList[row];
    NSString *stringURL = [[NSString alloc] initWithFormat:@"http://%@", [shop valueForKey:@"shop_logo"] ];
    NSURL *imageUrl = [NSURL URLWithString:stringURL];
    NSData *imgData = [NSData dataWithContentsOfURL:imageUrl];
    UIImage *tmpimage=[[UIImage alloc] initWithData:imgData];
    cell.shop_logo.image = tmpimage;
    cell.shop_name.text = [shop valueForKey:@"shop_name"];
    cell.stars.text =  [NSString stringWithFormat:@"%@",[shop valueForKey:@"stars"]];
    NSString *string_others = [[NSString alloc] initWithFormat:@"共售出%@份/%@起送/%@送达", [shop valueForKey:@"sold_amount"], [shop valueForKey:@"deliver_charge"], [shop valueForKey:@"service_time"]];
    cell.others.text = string_others;
    cell.introduce.text = [shop valueForKey:@"introduce"];
    
    return cell;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showFood"]) {
        FoodViewController *fv = segue.destinationViewController;
        NSInteger selectedIndex = [[self.myFavShopListTableView indexPathForSelectedRow] row];
        //通过行号查找flightDetailInfo中的数据
        NSDictionary *shopInfo = _shopList[selectedIndex];
        NSString *string_shop_id = [[NSString alloc] initWithFormat:@"%@",[shopInfo valueForKey:@"shop_id"]];
        fv.shop_id = string_shop_id;
        fv.shop_name = [shopInfo valueForKey:@"shop_name"];
        fv.shop_phone = [shopInfo valueForKey:@"shop_phone"];
        NSString *shop_logo_url = [shopInfo valueForKey:@"shop_logo"];
        NSString *pic_name = [shop_logo_url substringFromIndex:41];
        fv.shop_logo = pic_name;
        fv.deliver_charge = [shopInfo valueForKey:@"deliver_charge"];
        NSString *title = [shopInfo valueForKey:@"shop_name"];
        fv.navigationItem.title = title;
        
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

@end
