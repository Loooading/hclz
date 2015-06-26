//
//  FoodViewController.m
//  HaoCLZ
//
//  Created by Loading on 15/6/10.
//  Copyright (c) 2015年 liuhj. All rights reserved.
//

#import "FoodViewController.h"
#import "UIImageView+WebCache.h"


@interface FoodViewController () <UITableViewDataSource, UITableViewDelegate>
{
    NSMutableArray *_foodList;
    float allPrice;
    int foodNumber;
    NSString *foodAmount;
    NSMutableArray *_shopCarInfoArray;
    
}

@end

@implementation FoodViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.navigationController setNavigationBarHidden:NO];
    _shopCarInfoArray = [[NSMutableArray alloc] init];
    [self addNavRightButton];
    [self requestData];
}
-(void)addNavRightButton{
    UIImage *imgNormal = [UIImage imageNamed:@"add_fav"];
    UIButton *butt = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [butt setImage:imgNormal forState:UIControlStateNormal];
    [butt addTarget:self action:@selector(addFavorite) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithCustomView:butt];
//    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithImage:imgNormal style:UIBarButtonItemStyleBordered target:self action:@selector(addFavorite)];
//    rightButton.frame
    self.navigationItem.rightBarButtonItem = rightButton;

}
-(void)addFavorite
{
    AppDelegate *myDelegate = [[UIApplication sharedApplication] delegate];
    if (!myDelegate.uid) {
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        LoginViewController *lvc = [story instantiateViewControllerWithIdentifier:@"LoginViewController"];
        [self.navigationController pushViewController:lvc animated:YES];
    }
    else{
        NSString *path = [[NSString alloc] initWithFormat:@"/TakeOut/action/modify_collectionAdd"];
      
        NSMutableDictionary *para = [[NSMutableDictionary alloc] init];
        
        [para setValue:myDelegate.uid forKey:@"uid"];
        [para setValue:@"1" forKey:@"type"];
        [para setValue:self.shop_id forKey:@"shop_id"];
        
        MKNetworkEngine *engine = [[MKNetworkEngine alloc] initWithHostName:hostName customHeaderFields:nil];
        MKNetworkOperation *op = [engine operationWithPath:path params:para httpMethod:@"POST"];
        [op addCompletionHandler:^(MKNetworkOperation *operation){
            NSLog(@"respons string : %@", [operation responseString]);
            NSData *data = [operation responseData];
            NSDictionary *resDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            if(![[resDic valueForKey:@"status"] intValue])
            {
                [CustomViewController showMessage:@"收藏成功!"];
            }
            else{
                [CustomViewController showMessage:[resDic valueForKey:@"message"]];
            }
        }errorHandler:^(MKNetworkOperation *errorOp, NSError *err){
            NSLog(@"请求错误 : %@", [err localizedDescription]);
        }];
        [engine enqueueOperation:op];
    }
}

-(void)popFrontView
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Request Data

- (void)requestData{
    NSString *path = [[NSString alloc] initWithFormat:@"/TakeOut/action/msg_showFoods"];
    NSMutableDictionary *para = [[NSMutableDictionary alloc] init];
    [para setValue:self.shop_id forKey:@"shop_id"];
    
    MKNetworkEngine *engine = [[MKNetworkEngine alloc] initWithHostName:hostName customHeaderFields:nil];
    MKNetworkOperation *op = [engine operationWithPath:path params:para httpMethod:@"GET"];
    [op addCompletionHandler:^(MKNetworkOperation *operation){
        NSLog(@"respons string : %@", [operation responseString]);
        NSData *data = [operation responseData];
        NSDictionary *resDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        _foodList = [resDic valueForKey:@"foods"];
        //遍历食品列表,加入购物车列表
        for (int i = 0; i<_foodList.count; i++) {
            NSMutableDictionary *foodDic = _foodList[i];
            NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
            [dic setValue:[foodDic valueForKey:@"food_name"] forKey:@"food_name"];
            [dic setValue:@"0" forKey:@"food_number"];
            [dic setValue:@"0.0" forKey:@"food_price"];
            [dic setValue:[foodDic valueForKey:@"price"] forKey:@"price"];
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
//    cellIdentifer =  [NSString stringWithFormat:@"Cell%d%d", [indexPath section], [indexPath row]];
    cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifer];
    if(cell == nil)
    {
        cell = [[FoodTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifer];
    }
//    else//当页面拉动的时候 当cell存在并且最后一个存在 把它进行删除就出来一个独特的cell我们在进行数据配置即可避免
//    {
//        while ([cell.contentView.subviews lastObject] != nil) {
//            [(UIView *)[cell.contentView.subviews lastObject] removeFromSuperview];
//        }
//    }
    cell.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    NSUInteger row = [indexPath row];
    NSMutableDictionary *food = _foodList[row];
    //设置食物图片,从url中下载
    NSString *stringURL = [[NSString alloc] initWithFormat:@"http://%@", [food valueForKey:@"food_pic"] ];
    NSURL *imageUrl = [NSURL URLWithString:stringURL];
    [cell.food_pic sd_setImageWithURL:imageUrl placeholderImage:[UIImage imageNamed:@"icon"]];

    //设置食品名称
    cell.food_name.text = [food valueForKey:@"food_name"];
    cell.introduceLabel.text = [food valueForKey:@"food_introduce"];
    //设置食品数量,从_shopCarInfoArray取得
    cell.number.text = [_shopCarInfoArray[row] valueForKey:@"food_number"];
    //设置食品单价按钮标题为价格,圆角,tag为indexPath.row,点击执行加入购物车方法
    NSString *price = [[NSString alloc] initWithFormat:@"￥%@", [food valueForKey:@"price"]];
    [cell.buttonPrice setTitle:price forState:UIControlStateNormal];
    cell.buttonPrice.layer.cornerRadius = 5.0;
    [cell.buttonPrice setTag:indexPath.row];
    [cell.buttonPrice addTarget:self action:@selector(addToShopCar:event:) forControlEvents:UIControlEventTouchUpInside];
    //初始化minusButton
    [cell.minusButton setHidden:YES];
    cell.minusButton.layer.cornerRadius = 5.0;
    //判断食品数量,如大于0则显示减按钮
    int num =  [[_shopCarInfoArray[row] valueForKey:@"food_number"] intValue];
    if (num > 0) {
        [cell.minusButton setHidden:NO];
        [cell.minusButton addTarget:self action:@selector(minusFromShopCar:event:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return cell;
}

#pragma mark - Shop Car

//从购物车减去商品
-(void)minusFromShopCar:(id)sender event:(id)event{
    NSSet *touches =[event allTouches];
    UITouch *touch =[touches anyObject];
    CGPoint currentTouchPosition = [touch locationInView:_foodListTableView];
    NSIndexPath *indexPath= [_foodListTableView indexPathForRowAtPoint:currentTouchPosition];
    if (indexPath!= nil)
    {
        NSUInteger rowIndex = indexPath.row;
        NSDictionary *dic = [_foodList objectAtIndex:rowIndex];
        float addPrice = [[dic valueForKey:@"price"] floatValue];
        allPrice -= addPrice;
        NSString *totalPrice = [[NSString alloc] initWithFormat:@"￥%.1f", allPrice];
        self.totalPrice.text = totalPrice;
        foodNumber -= 1;
        self.foodNumber.text = [[NSString alloc] initWithFormat:@"%i份", foodNumber];
        int num =  [[_shopCarInfoArray[rowIndex] valueForKey:@"food_number"] intValue];
        num -= 1;
        //修改购物车表
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
//        for (int i = 0; i < _shopCarInfoArray.count; i++) {
//            NSMutableDictionary *shopCarDic = _shopCarInfoArray[i];
//            NSString *food_number_cond = [shopCarDic valueForKey:@"food_number"];
//            if ([food_number_cond isEqualToString:@"0"]) {
//                [_shopCarInfoArray removeObject:shopCarDic];
//            }
//        }
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

        ShopCarViewController *scv = [[ShopCarViewController alloc] init];
        scv = segue.destinationViewController;
        scv.totalPrice = allPrice;
        scv.foodNumber = foodNumber;
        scv.shopCarInfo = _shopCarInfoArray;
        scv.shop_id = self.shop_id;
        scv.shop_name = self.shop_name;
        scv.shop_phone = self.shop_phone;
        scv.shop_logo = self.shop_logo;
        scv.deliver_charge = self.deliver_charge;
        //请求类型,1为店铺,0为电子商城
        scv.foodRequestType = 1;
        scv.navigationController.title = @"美食篮子";
    }
    
    if ([segue.identifier isEqualToString:@"showFoodDetail"]) {
        FoodDetailViewController *fdvc = [[FoodDetailViewController alloc] init];
        fdvc = segue.destinationViewController;
        FoodTableViewCell *cell =  (FoodTableViewCell *)[_foodListTableView cellForRowAtIndexPath:[_foodListTableView indexPathForSelectedRow]];
        fdvc.intrduce = cell.introduceLabel.text;
        fdvc.food_image = cell.food_pic.image;
        fdvc.food_name = cell.food_name.text;
        fdvc.food_price = cell.buttonPrice.titleLabel.text;
        fdvc.title = cell.food_name.text;
        
    }
}

@end
