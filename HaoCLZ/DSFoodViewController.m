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
#import "UIImageView+WebCache.h"


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
    
    MKNetworkEngine *engine = [[MKNetworkEngine alloc] initWithHostName:hostName customHeaderFields:nil];
    MKNetworkOperation *op = [engine operationWithPath:path params:para httpMethod:@"GET"];
    [op addCompletionHandler:^(MKNetworkOperation *operation){
        NSLog(@"respons string : %@", [operation responseString]);
        NSData *data = [operation responseData];
        NSDictionary *resDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        _foodList = [resDic valueForKey:@"cfood"];
        //遍历食品列表,取有用字段,逐个加入购物车列表
        for (int i = 0; i<_foodList.count; i++) {
            NSMutableDictionary *foodDic = _foodList[i];
            NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
            [dic setValue:[foodDic valueForKey:@"food_name"] forKey:@"food_name"];
            [dic setValue:[foodDic valueForKey:@"food_id"] forKey:@"food_id"];
            [dic setValue:[foodDic valueForKey:@"price"] forKey:@"price"];
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
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
    
    cell.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    NSUInteger row = [indexPath row];
    NSMutableDictionary *food = _foodList[row];
    //设置食物图片,从url中下载
    NSString *stringURL = [[NSString alloc] initWithFormat:@"http://%@", [food valueForKey:@"food_pic"] ];
    NSURL *imageUrl = [NSURL URLWithString:stringURL];
    [cell.food_pic sd_setImageWithURL:imageUrl placeholderImage:[UIImage imageNamed:@"icon"]];
    //设置食品名称
    cell.food_name.text = [food valueForKey:@"food_name"];
    //设置食品介绍
    cell.introduceLabel.text = [food valueForKey:@"introduce"];
    //设置食品数量,从_shopCarInfoArray取得,_shopCarInfoArray在做购物车增加删除操作时被更改
    cell.number.text = [_shopCarInfoArray[row] valueForKey:@"food_number"];
    //设置食品单价按钮标题为价格,圆角,点击执行加入购物车方法
    NSString *price = [[NSString alloc] initWithFormat:@"￥%@", [food valueForKey:@"price"]];
    [cell.buttonPrice setTitle:price forState:UIControlStateNormal];
    cell.buttonPrice.layer.cornerRadius = 5.0;
    [cell.buttonPrice setTag:indexPath.row];
    [cell.buttonPrice addTarget:self action:@selector(addToShopCar:event:) forControlEvents:UIControlEventTouchUpInside];
    //初始化minusButton,默认设置为隐藏
    [cell.minusButton setHidden:YES];
    cell.minusButton.layer.cornerRadius = 5.0;
    //判断食品数量,如大于0则显示减按钮
    int num = [[_shopCarInfoArray[row] valueForKey:@"food_number"] intValue];;
    if (num > 0) {
            [cell.minusButton setHidden:NO];
            [cell.minusButton addTarget:self action:@selector(minusFromShopCar:event:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return cell;
}

#pragma mark - Shop Car

//从购物车减去商品
-(void)minusFromShopCar:(id)sender event:(id)event{
    //从touch点获得indexpath
    NSSet *touches =[event allTouches];
    UITouch *touch =[touches anyObject];
    CGPoint currentTouchPosition = [touch locationInView:_foodListTableView];
    NSIndexPath *indexPath= [_foodListTableView indexPathForRowAtPoint:currentTouchPosition];
    if (indexPath!= nil)
    {
        NSUInteger rowIndex = indexPath.row;
        NSDictionary *dic = [_foodList objectAtIndex:rowIndex];
        float addPrice = [[dic valueForKey:@"price"] floatValue];
        //总价减去购物车中食品单价并配合"￥"显示
        allPrice -= addPrice;
        NSString *totalPrice = [[NSString alloc] initWithFormat:@"￥%.1f", allPrice];
        self.totalPrice.text = totalPrice;
        //每点一次减按钮,总购买数量减去1
        foodNumber -= 1;
        self.foodNumber.text = [[NSString alloc] initWithFormat:@"%i份", foodNumber];
        //每点一次减按钮,单个食品购买数量减去1
        int num =  [[_shopCarInfoArray[rowIndex] valueForKey:@"food_number"] intValue];
        num -= 1;
        //修改购物车列表,刷新tableview
        [_shopCarInfoArray[rowIndex] setValue:[NSString stringWithFormat:@"%i",num] forKey:@"food_number"];
        float foodPrice = addPrice * num;
        [_shopCarInfoArray[rowIndex] setValue:[NSString stringWithFormat:@"￥%.1f",foodPrice] forKey:@"food_price"];
        [_foodListTableView reloadData];
        
    }
}

//加入购物车
- (IBAction)addToShopCar:(id)sender event:(id)event{
    NSSet *touches =[event allTouches];
    UITouch *touch =[touches anyObject];
    CGPoint currentTouchPosition = [touch locationInView:_foodListTableView];
    NSIndexPath *indexPath= [_foodListTableView indexPathForRowAtPoint:currentTouchPosition];
    if (indexPath!= nil)
    {
        NSUInteger rowIndex = indexPath.row;
        NSDictionary *dic = [_foodList objectAtIndex:rowIndex];
        float addPrice = [[dic valueForKey:@"price"] floatValue];
        allPrice += addPrice;
        NSString *totalPrice = [[NSString alloc] initWithFormat:@"￥%.1f", allPrice];
        self.totalPrice.text = totalPrice;
        foodNumber += 1;
        self.foodNumber.text = [[NSString alloc] initWithFormat:@"%i份", foodNumber];
        int num =  [[_shopCarInfoArray[rowIndex] valueForKey:@"food_number"] intValue];
        num += 1;
        //修改购物车表
        [_shopCarInfoArray[rowIndex] setValue:[NSString stringWithFormat:@"%i",num] forKey:@"food_number"];
        float foodPrice = addPrice * num;
        [_shopCarInfoArray[rowIndex] setValue:[NSString stringWithFormat:@"￥%.1f",foodPrice] forKey:@"food_price"];
        [_foodListTableView reloadData];
        
    }
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
        fdvc.intrduce = cell.introduceLabel.text;
        fdvc.title = cell.food_name.text;
        
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
