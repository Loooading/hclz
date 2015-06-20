//
//  DSFoodViewController.m
//  HaoCLZ
//
//  Created by Loading on 15/6/15.
//  Copyright (c) 2015年 liuhj. All rights reserved.
//

#import "DSFoodViewController.h"
#import "FoodTableViewCell.h"
#import "ShopCarViewController.h"
#import "FoodDetailViewController.h"

@interface DSFoodViewController ()
{
    NSMutableArray *_foodList;
    NSMutableArray *_shopCarInfoArray;
    float allPrice;
    int foodNumber;

}

@end

@implementation DSFoodViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self addMenuButton];
    [self requestData];
    _shopCarInfoArray = [[NSMutableArray alloc] init];


}

#pragma mark - Request Data

- (void)requestData{
    NSString *path = [[NSString alloc] initWithFormat:@"/TakeOut/action/msg_getCFoodList"];
    NSMutableDictionary *para = [[NSMutableDictionary alloc] init];
    [para setValue:@"0" forKey:@"index"];
    
    MKNetworkEngine *engine = [[MKNetworkEngine alloc] initWithHostName:@"101.200.179.69:8080" customHeaderFields:nil];
    MKNetworkOperation *op = [engine operationWithPath:path params:para httpMethod:@"GET"];
    [op addCompletionHandler:^(MKNetworkOperation *operation){
        NSLog(@"respons string : %@", [operation responseString]);
        NSData *data = [operation responseData];
        NSDictionary *resDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        _foodList = [resDic valueForKey:@"cfood"];
        //遍历食品列表,加入购物车列表
        for (int i = 0; i<_foodList.count; i++) {
            NSMutableDictionary *foodDic = _foodList[i];
            NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
            [dic setValue:[foodDic valueForKey:@"food_name"] forKey:@"food_name"];
            [dic setValue:[foodDic valueForKey:@"food_id"] forKey:@"food_id"];

            [dic setValue:@"0" forKey:@"food_number"];
            [dic setValue:@"0.0" forKey:@"food_price"];
            [_shopCarInfoArray addObject:dic];
        }
        [self.foodListTableView reloadData];
    }errorHandler:^(MKNetworkOperation *errorOp, NSError *err){
        NSLog(@"请求错误 : %@", [err localizedDescription]);
    }];
    [engine enqueueOperation:op];
}



#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _foodList.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifer;
    FoodTableViewCell * cell ;
    cellIdentifer = @"FoodTableViewCell";
    cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifer];
    if(!cell)
    {
        cell = [[FoodTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifer];
    }
    
    cell.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    NSUInteger row = [indexPath row];
    NSMutableDictionary *food = _foodList[row];
    //设置食物图片,从url中下载
    NSString *stringURL = [[NSString alloc] initWithFormat:@"http://%@", [food valueForKey:@"food_pic"] ];
    NSURL *imageUrl = [NSURL URLWithString:stringURL];
    NSData *imgData = [NSData dataWithContentsOfURL:imageUrl];
    UIImage *tmpimage=[[UIImage alloc] initWithData:imgData];
    cell.food_pic.image = tmpimage;
    //设置食品名称
    cell.food_name.text = [food valueForKey:@"food_name"];
    //设置食品单价按钮标题为价格,圆角,tag为indexPath.row,点击执行加入购物车方法
    NSString *price = [[NSString alloc] initWithFormat:@"￥%@", [food valueForKey:@"price"]];
    [cell.buttonPrice setTitle:price forState:UIControlStateNormal];
    cell.buttonPrice.layer.cornerRadius = 5.0;
    [cell.buttonPrice setTag:indexPath.row];
    [cell.buttonPrice addTarget:self action:@selector(addToShopCar:) forControlEvents:UIControlEventTouchUpInside];
    //设置数量label圆角
    cell.number.layer.cornerRadius = 10.0;
    //判断食品数量,如大于0则添加减按钮
    int num =  [cell.number.text intValue];
    if (num > 0) {
        UIButton *minusBt = (UIButton *)[cell.contentView viewWithTag:(indexPath.row+100)];
        //通过tag获得减按钮,如没有则新建并添加到cell
        if (!minusBt) {
            minusBt = [[UIButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width / 3 * 2 - 40, 21, 30, 30)];
            minusBt.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
            [minusBt setBackgroundColor:[UIColor colorWithRed:40.0/255 green:125.0/255 blue:193.0/255 alpha:1]];
            [minusBt setTitle:@"—" forState:UIControlStateNormal];
            [minusBt.titleLabel setTextColor:[UIColor whiteColor]];
            //设置按钮tag为indexPath.row+100
            [minusBt setTag:(indexPath.row+100)];
            minusBt.layer.cornerRadius = 5.0;
            [cell.contentView addSubview:minusBt];
            [minusBt addTarget:self action:@selector(minusFromShopCar:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    else
    {
        UIButton *minusBt = (UIButton *)[cell.contentView viewWithTag:(indexPath.row+100)];
        if (minusBt) {
            [minusBt removeFromSuperview];
        }
    }
    
    return cell;
}
#pragma mark - Shop Car

//从购物车减去商品
-(void)minusFromShopCar:(UIButton *)bt
{
    //从减按钮获取tag,减去100则为indexPath.row
    NSUInteger rowIndex = bt.tag - 100;
    NSDictionary *dic = [_foodList objectAtIndex:(rowIndex)];
    //界面显示设置
    float minusPrice = [[dic valueForKey:@"price"] floatValue];
    allPrice -= minusPrice;
    NSString *totalPrice = [[NSString alloc] initWithFormat:@"共￥%.1f", allPrice];
    self.totalPrice.text = totalPrice;
    
    foodNumber -= 1;
    self.foodNumber.text = [[NSString alloc] initWithFormat:@"%i份", foodNumber];
    
    FoodTableViewCell *cell = (FoodTableViewCell *)[[bt superview] superview];
    int num =  [cell.number.text intValue];
    num -= 1;
    cell.number.text = [NSString stringWithFormat:@"%i",num];
    //修改购物车表
    [_shopCarInfoArray[rowIndex] setValue:[NSString stringWithFormat:@"%i",num] forKey:@"food_number"];
    float foodPrice = minusPrice * num;
    [_shopCarInfoArray[rowIndex] setValue:[NSString stringWithFormat:@"￥%.1f",foodPrice] forKey:@"food_price"];
    
    
    [_foodListTableView reloadData];
    
}

//加入购物车
- (void)addToShopCar:(UIButton *)bt{
    
    //从加入购物车按钮获取tag,为indexPath.row
    NSUInteger rowIndex = bt.tag;
    NSDictionary *dic = [_foodList objectAtIndex:rowIndex];
    float addPrice = [[dic valueForKey:@"price"] floatValue];
    allPrice += addPrice;
    NSString *totalPrice = [[NSString alloc] initWithFormat:@"共￥%.1f", allPrice];
    self.totalPrice.text = totalPrice;
    
    foodNumber += 1;
    self.foodNumber.text = [[NSString alloc] initWithFormat:@"%i份", foodNumber];
    
    FoodTableViewCell *cell = (FoodTableViewCell *)[[bt superview] superview];
    int num =  [cell.number.text intValue];
    num += 1;
    cell.number.text = [NSString stringWithFormat:@"%i",num];
    //修改购物车表
    [_shopCarInfoArray[rowIndex] setValue:[NSString stringWithFormat:@"%i",num] forKey:@"food_number"];
    float foodPrice = addPrice * num;
    [_shopCarInfoArray[rowIndex] setValue:[NSString stringWithFormat:@"￥%.1f",foodPrice] forKey:@"food_price"];
    
    [_foodListTableView reloadData];
}

- (IBAction)goToNextStep:(id)sender{
    AppDelegate *myDelegate = [[UIApplication sharedApplication] delegate];
    
    if (!foodNumber) {
        [CustomViewController showMessage:@"您未选择任何商品!"];
        return;
    }
    
    if(myDelegate.uid){
        [self performSegueWithIdentifier:@"showShopCar" sender:nil];
    }
    else{
        [self performSegueWithIdentifier:@"goToLogin" sender:nil];
    }
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
    
    
    if ([segue.identifier isEqualToString:@"showShopCar"]) {
        for (int i = 0; i < _shopCarInfoArray.count; i++) {
            NSMutableDictionary *shopCarDic = _shopCarInfoArray[i];
            NSString *food_number_cond = [shopCarDic valueForKey:@"food_number"];
            if ([food_number_cond isEqualToString:@"0"]) {
                [_shopCarInfoArray removeObject:shopCarDic];
            }
        }
        ShopCarViewController *scv = [[ShopCarViewController alloc] init];
        scv = segue.destinationViewController;
        scv.totalPrice = allPrice;
        scv.foodNumber = foodNumber;
        scv.shopCarInfo = _shopCarInfoArray;
        scv.deliver_charge = @"0";
        //电子商城请求
        scv.foodRequestType = 0;

    }
    
    if ([segue.identifier isEqualToString:@"showFoodDetail"]) {
        FoodDetailViewController *fdvc = [[FoodDetailViewController alloc] init];
        fdvc = segue.destinationViewController;
        FoodTableViewCell *cell =  (FoodTableViewCell *)[_foodListTableView cellForRowAtIndexPath:[_foodListTableView indexPathForSelectedRow]];
        fdvc.food_image = cell.food_pic.image;
        fdvc.food_name = cell.food_name.text;
        fdvc.food_price = cell.buttonPrice.titleLabel.text;
        fdvc.title = cell.food_name.text;
        
    }
}

@end
