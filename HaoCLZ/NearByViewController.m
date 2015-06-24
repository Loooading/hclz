//
//  ViewController.m
//  HaoCLZ
//
//  Created by Loading on 15/6/8.
//  Copyright (c) 2015年 liuhj. All rights reserved.
//

#import "NearByViewController.h"
#import "BaiduMapViewController.h"

@interface NearByViewController () <UITableViewDataSource, UITableViewDelegate, SINavigationMenuDelegate>
{
    NSMutableArray *_shopList;
    SINavigationMenuView *_Navmenu;
    NSArray *itemsArray;
}

@end

@implementation NearByViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addMenuButton];
    [self addNavigationMenuView];
    [self requestDataWithType:@"0"];
    [self addNavRightButton];

    itemsArray = @[@"社区店", @"校园店", @"商务店"];
}

-(void)addNavRightButton{
    UIImage *imgNormal = [UIImage imageNamed:@"map"];
    UIButton *butt = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [butt setImage:imgNormal forState:UIControlStateNormal];
    [butt addTarget:self action:@selector(showBaiduMapView) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithCustomView:butt];
    //    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithImage:imgNormal style:UIBarButtonItemStyleBordered target:self action:@selector(addFavorite)];
    //    rightButton.frame
    self.navigationItem.rightBarButtonItem = rightButton;
}
-(void)showBaiduMapView
{
    [self performSegueWithIdentifier:@"showBaiduMap" sender:nil];

}

#pragma mark - Request Data

- (void)requestDataWithType:(NSString *)type{
    AppDelegate *myDelegate = [[UIApplication sharedApplication] delegate];
    NSString *path = [[NSString alloc] initWithFormat:@"/TakeOut/action/msg_shopNearby"];
    NSMutableDictionary *para = [[NSMutableDictionary alloc] init];
    [para setValue:type forKey:@"type"];
    NSString *lat = [[NSString alloc] initWithFormat:@"%f", myDelegate.latitude ];
    NSString *lon = [[NSString alloc] initWithFormat:@"%f", myDelegate.longitude ];
    
    [para setValue:lat forKey:@"latitude"];
    [para setValue:lon forKey:@"longitude"];

//    [para setValue:@"26.456654" forKey:@"latitude"];
//    [para setValue:@"116.12516" forKey:@"longitude"];
    [para setValue:@"100" forKey:@"amount"];
    
    MKNetworkEngine *engine = [[MKNetworkEngine alloc] initWithHostName:@"101.200.179.69:8080" customHeaderFields:nil];
    MKNetworkOperation *op = [engine operationWithPath:path params:para httpMethod:@"GET"];
    [op addCompletionHandler:^(MKNetworkOperation *operation){
        NSLog(@"respons string : %@", [operation responseString]);
        NSData *data = [operation responseData];
        NSDictionary *resDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        _shopList = [resDic valueForKey:@"shopNearby"];
        [self.shopsLIstTableView reloadData];
    }errorHandler:^(MKNetworkOperation *errorOp, NSError *err){
        NSLog(@"请求错误 : %@", [err localizedDescription]);
    }];
    [engine enqueueOperation:op];
}

#pragma mark - Add NavigationMenuView
-(void)addNavigationMenuView{
    if (self.navigationItem) {
        CGRect frame = CGRectMake(0.0, 0.0, 200.0, self.navigationController.navigationBar.bounds.size.height);
        _Navmenu = [[SINavigationMenuView alloc] initWithFrame:frame title:@"社区店"];
        [_Navmenu displayMenuInView:self.view];
        _Navmenu.items = @[@"社区店", @"校园店", @"商务店"];
        _Navmenu.delegate = self;
        self.navigationItem.titleView = _Navmenu;
    }
}
#pragma mark - NavigationMenuView Delegate
- (void)didSelectItemAtIndex:(NSUInteger)index
{
//    NSLog(@"did selected item at index %lu", (unsigned long)index);
    NSString *requestType = [[NSString alloc] initWithFormat:@"%lu",(unsigned long)index];
    [self requestDataWithType:requestType];
    NSString *menuButtonTitleString = itemsArray[index];
    _Navmenu.menuButton.title.text = menuButtonTitleString;
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
    NSMutableDictionary *shop = [_shopList[row] valueForKey:@"shops"];
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

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
////    UINavigationController *nav = self.navController;
//
//    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//    FoodViewController *fv = [story instantiateViewControllerWithIdentifier:@"FoodViewController"];
//    NSDictionary *shopInfo = _shopList[indexPath.row];
//    fv.shop_id = [[shopInfo valueForKey:@"shops"] valueForKey:@"shop_id"];
//    fv.shop_name = [[shopInfo valueForKey:@"shops"] valueForKey:@"shop_name"];
//    fv.shop_phone = [[shopInfo valueForKey:@"shops"] valueForKey:@"shop_phone"];
//    fv.shop_logo = [[shopInfo valueForKey:@"shops"] valueForKey:@"shop_logo"];
//    fv.deliver_charge = [[shopInfo valueForKey:@"shops"] valueForKey:@"deliver_charge"];
//    NSString *title = [[shopInfo valueForKey:@"shops"] valueForKey:@"shop_name"];
//    fv.navigationItem.title = title;
//    [self.navigationController pushViewController:fv animated:YES];
//}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showFood"]) {
        FoodViewController *fv = segue.destinationViewController;
        NSInteger selectedIndex = [[self.shopsLIstTableView indexPathForSelectedRow] row];
        //通过行号查找flightDetailInfo中的数据
        NSDictionary *shopInfo = _shopList[selectedIndex];
        NSString *string_shop_id = [[NSString alloc] initWithFormat:@"%@",[[shopInfo valueForKey:@"shops"] valueForKey:@"shop_id"]];
        fv.shop_id = string_shop_id;
        fv.shop_name = [[shopInfo valueForKey:@"shops"] valueForKey:@"shop_name"];
        fv.shop_phone = [[shopInfo valueForKey:@"shops"] valueForKey:@"shop_phone"];
        NSString *shop_logo_url = [[shopInfo valueForKey:@"shops"] valueForKey:@"shop_logo"];
        NSString *pic_name = [shop_logo_url substringFromIndex:41];
        fv.shop_logo = pic_name;
        fv.deliver_charge = [[shopInfo valueForKey:@"shops"] valueForKey:@"deliver_charge"];
        NSString *title = [[shopInfo valueForKey:@"shops"] valueForKey:@"shop_name"];
        fv.navigationItem.title = title;
    }
    if ([segue.identifier isEqualToString:@"showBaiduMap"]) {
        BaiduMapViewController *bmv = segue.destinationViewController;
        bmv.shopList = _shopList;
    }

    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
