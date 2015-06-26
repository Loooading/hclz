//
//  OrderLIstViewController.m
//  HaoCLZ
//
//  Created by Loading on 15/6/14.
//  Copyright (c) 2015年 liuhj. All rights reserved.
//

#import "OrderLIstViewController.h"
#import "OrderListTableViewCell.h"
#import "SINavigationMenuView.h"
#import "OrderDetailViewController.h"
#import "UIImageView+WebCache.h"


@interface OrderLIstViewController () <SINavigationMenuDelegate>
{
    NSMutableArray *_resOrderList;
    NSMutableArray *_orderList;
    SINavigationMenuView *_Navmenu;
    NSArray *_items;

}
@end

@implementation OrderLIstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _items = @[@"未接单", @"已接单", @"已完成",@"已取消"];
    _orderList = [[NSMutableArray alloc] init];
    [self addMenuButton];
    [self addNavigationMenuView];
    [self requestDataWithType:0 isDSrder:self.orderRequestType];
}

#pragma mark - Add NavigationMenuView
-(void)addNavigationMenuView{
    if (self.navigationItem) {
        CGRect frame = CGRectMake(0.0, 0.0, 200.0, self.navigationController.navigationBar.bounds.size.height);
        _Navmenu = [[SINavigationMenuView alloc] initWithFrame:frame title:@"未接单"];
        [_Navmenu displayMenuInView:self.view];
        _Navmenu.items = _items;
        _Navmenu.delegate = self;
        self.navigationItem.titleView = _Navmenu;
    }
}
#pragma mark - NavigationMenuView Delegate
- (void)didSelectItemAtIndex:(NSUInteger)index
{
    //    NSLog(@"did selected item at index %lu", (unsigned long)index);
    [self requestDataWithType:index isDSrder:self.orderRequestType];
    NSString *menuButtonTitleString = _items[index];
    _Navmenu.menuButton.title.text = menuButtonTitleString;
    
}

#pragma mark - Request Data
//根据orderRequestType访问商城或者普通订单,1为普通,0为商城
- (void)requestDataWithType:(NSUInteger) type isDSrder:(NSUInteger) orderReqType{
    NSString *path;
    if (orderReqType) {
        //普通订单
        path = [[NSString alloc] initWithFormat:@"/TakeOut/action/msg_myOrderHistory"];

    }
    else
    {
        //商城订单
        path = [[NSString alloc] initWithFormat:@"/TakeOut/action/msg_myCOrder"];

    }
    NSMutableDictionary *para = [[NSMutableDictionary alloc] init];
    AppDelegate *myDelegate = [[UIApplication sharedApplication] delegate];
    NSLog(@"%@",myDelegate.uid);
    [para setValue:myDelegate.uid forKey:@"uid"];
    MKNetworkEngine *engine = [[MKNetworkEngine alloc] initWithHostName:hostName customHeaderFields:nil];
    MKNetworkOperation *op = [engine operationWithPath:path params:para httpMethod:@"GET"];
    [op addCompletionHandler:^(MKNetworkOperation *operation){
        NSLog(@"respons string : %@", [operation responseString]);
        NSData *data = [operation responseData];
        NSDictionary *resDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        if (orderReqType)
        {
            //普通订单
            _resOrderList = [resDic valueForKey:@"orderHistories"];
        }
        else{
            //商城订单
            _resOrderList = [resDic valueForKey:@"corder"];
        }
        [_orderList removeAllObjects];
        //数据处理
        //遍历返回的订单数组,如果订单状态与请求的订单类型相同,则放入_orderList,通过tableview显示出来
        for (int i = 0; i <_resOrderList.count; i++) {
            NSMutableDictionary *dicTmp =  [_resOrderList objectAtIndex:i];
            NSUInteger orderState = [[dicTmp valueForKey:@"state"] intValue];
            NSUInteger visible = [[dicTmp valueForKey:@"visible"] intValue];
            //如果订单的类型与导航栏菜单的index相同,且订单可见,则加入订单显示表
            if (orderState == type && !visible) {
                [_orderList addObject:dicTmp];
            }
        }
        [self.orderListTableView reloadData];
    }errorHandler:^(MKNetworkOperation *errorOp, NSError *err){
        NSLog(@"请求错误 : %@", [err localizedDescription]);
    }];
    [engine enqueueOperation:op];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _orderList.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifer;
    OrderListTableViewCell * cell ;
    cellIdentifer = @"OrderListTableViewCell";
    cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifer];
    if(!cell)
    {
        cell = [[OrderListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifer];
    }
    cell.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    NSUInteger row = [indexPath row];
    NSMutableDictionary *orderInfo = _orderList[row];
    //如果是商城订单,则需要解析返回来的jsonArray,否则直接显示订单信息即可
    if (!self.orderRequestType)
    {
        //解析jsonArray
        NSData *data = [[orderInfo valueForKey:@"foodAmount"] dataUsingEncoding:NSUTF8StringEncoding];
        NSArray *foodAmountArray =[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        NSString *foodAmountString = @"";
        for (NSMutableDictionary *foodAmountDic in foodAmountArray) {
            NSString *foodNumberTmp = [[NSString alloc] initWithFormat:@"%@份", [foodAmountDic  valueForKey:@"food_num"]];
            foodAmountString = [foodAmountString stringByAppendingString:foodNumberTmp];
            foodAmountString = [foodAmountString stringByAppendingString:[foodAmountDic valueForKey:@"food_name"]];
            foodAmountString = [foodAmountString stringByAppendingString:@";"];
        }

        cell.foodAmount_label.text = foodAmountString;
        //订单店铺名称显示"电子商城"
        cell.shop_name_logo.text = @"电子商城";
    }
    else{
        cell.foodAmount_label.text = [orderInfo valueForKey:@"foodAmount"];
        cell.shop_name_logo.text = [orderInfo valueForKey:@"shop_name"];
        NSString *stringURL = [[NSString alloc] initWithFormat:@"http://%@", [orderInfo valueForKey:@"shop_logo"]];
        NSURL *imageUrl = [NSURL URLWithString:stringURL];
        [cell.shop_logo_imgaeVIew sd_setImageWithURL:imageUrl placeholderImage:[UIImage imageNamed:@"icon"]];

    }
    cell.date_label.text = [orderInfo valueForKey:@"date"];
    NSUInteger orderState = [[orderInfo valueForKey:@"state"] intValue];
    NSString *stateInString;
    switch (orderState) {
        case 0:
            stateInString = @"未接单";
            break;
        case 1:
            stateInString = @"已接单";
            break;
        case 2:
            stateInString = @"交易完成";
            break;
        case 3:
            stateInString = @"交易取消";
            break;
        default:
            stateInString = @"未知状态";
            break;
    }
    cell.state_label.text = stateInString;
    return cell;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"showOrderDetail"]) {
        OrderDetailViewController *odvc = [[OrderDetailViewController alloc] init];
        odvc = segue.destinationViewController;
//        OrderListTableViewCell *cell =  (OrderListTableViewCell *)[_orderListTableView cellForRowAtIndexPath:[_orderListTableView indexPathForSelectedRow]];
        NSInteger rowNumber = [_orderListTableView indexPathForSelectedRow].row;
        odvc.orderDetailInfo = [_orderList objectAtIndex:rowNumber];
        odvc.orderRequestType = self.orderRequestType;
    }

}


@end
