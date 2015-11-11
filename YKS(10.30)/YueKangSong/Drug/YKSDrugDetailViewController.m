//
//  YKSDrugDetailViewController.m
//  YueKangSong
//
//  Created by gongliang on 15/5/16.
//  Copyright (c) 2015年 YKS. All rights reserved.
//

#import "YKSDrugDetailViewController.h"
#import "GZBaseRequest.h"
#import "YKSDrugInfoCell.h"
#import <ImagePlayerView/ImagePlayerView.h>
#import "YKSConstants.h"
#import <UITableView+FDTemplateLayoutCell/UITableView+FDTemplateLayoutCell.h>
#import "YKSTools.h"
#import "YKSUserModel.h"
#import "YKSSingleBuyViewController.h"
#import "YKSAddAddressVC.h"
#import "YKSAddressListViewController.h"
#import "YKSDrugShuoMingViewController.h" // 药品说明
#import "YKSMyAddressViewcontroller.h"
#import "YKSSelectAddressView.h"

@interface YKSDrugDetailViewController () <UITableViewDelegate, ImagePlayerViewDelegate,UIScrollViewDelegate,UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
//@property (weak, nonatomic) IBOutlet ImagePlayerView *_headerView;
@property (strong, nonatomic) NSArray *imageURLStrings;
@property (weak, nonatomic) IBOutlet UIButton *shoppingCartButton;

@property (strong, nonatomic) UIPageControl *pageControl;
@property (strong, nonatomic) UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UIView *headerView;

@property (assign, nonatomic) BOOL isCreat;

@property (strong, nonatomic) NSDictionary *info;



@end

@implementation YKSDrugDetailViewController

#pragma mark - ViewController Methods
- (void)viewDidLoad {
    [super viewDidLoad];
    _headerView.bounds = CGRectMake(0, 0, SCREEN_WIDTH, self.view.bounds.size.height*0.5);
    _imageURLStrings = [_drugInfo[@"banners"] componentsSeparatedByString:@","]; // 把后台传回来的图片分割为N个部分。

    _scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, _headerView.bounds.size.height)];
    _scrollView.pagingEnabled = YES;
    _scrollView.bounces = NO;
    _scrollView.delegate = self;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.contentSize = CGSizeMake(SCREEN_WIDTH*_imageURLStrings.count, 0);
    for (int i = 0; i<_imageURLStrings.count; i++) {
        UIImageView *iv = [[UIImageView alloc]initWithFrame:CGRectMake(i*SCREEN_WIDTH, 0, SCREEN_WIDTH, _headerView.bounds.size.height)];
        iv.contentMode = UIViewContentModeScaleAspectFit;
        [iv sd_setImageWithURL:[NSURL URLWithString:_imageURLStrings[i]] placeholderImage:[UIImage imageNamed:@"defatul320"]];
        [_scrollView addSubview:iv];
    }
    
//    UIView *headerView = [[UIView alloc]initWithFrame:];
    
    
    [self.tableView.tableHeaderView addSubview:_scrollView];
    
    _pageControl = [[UIPageControl alloc]init];
//    _pageControl.hidesForSinglePage = YES;
    _pageControl.contentMode = UIViewContentModeCenter;
    _pageControl.numberOfPages = _imageURLStrings.count;
    CGSize qsize = [_pageControl sizeForNumberOfPages:_imageURLStrings.count];
    CGRect rect = _pageControl.bounds;
    rect.size = qsize;
    _pageControl.frame = CGRectMake((_scrollView.bounds.size.width-qsize.width)*0.5, _scrollView.bounds.size.height-15, qsize.width, qsize.height);
    
//    _pageControl.center = CGPointMake(SCREEN_WIDTH/2, _scrollView.bounds.size.height-5);
    [self.tableView.tableHeaderView addSubview:_pageControl];
    _pageControl.currentPage = 0;
    _pageControl.currentPageIndicatorTintColor = [UIColor redColor];
    _pageControl.pageIndicatorTintColor = [UIColor colorWithRed:50.0/255 green:143.0/255 blue:250.0/255 alpha:1];
//    _pageControl.pageIndicatorTintColor = [UIColor blueColor];
    
    // Do any additional setup after loading the view.
//    __headerView.imagePlayerViewDelegate = self;
//    __headerView.scrollInterval = 99999;
//    __headerView.pageControlPosition = ICPageControlPosition_BottomRight;
//    [self._headerView reloadData];
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    NSInteger page = scrollView.contentOffset.x/SCREEN_WIDTH;
    _pageControl.currentPage = page;
}


#pragma mark - custom
- (void)collectAction:(UIButton *)sender {
    if (![YKSUserModel isLogin]) {
        [YKSTools login:self];
        return ;
    }

    if ([sender.imageView.image isEqual:[UIImage imageNamed:@"collect_selected"]]) {
        [GZBaseRequest deleteCollectByGid:_drugInfo[@"gid"]
                                 callback:^(id responseObject, NSError *error) {
                                     if (error) {
                                         [self showToastMessage:@"网络加载失败"];
                                         return ;
                                     }
                                     if (ServerSuccess(responseObject)) {
                                         
                                         [sender setImage:[UIImage imageNamed:@"collect_normal"]
                                                 forState:UIControlStateNormal];
                                     } else {
                                         [self showToastMessage:responseObject[@"msg"]];
                                     }
        }];
    } else {
        [GZBaseRequest addCollectByGid:_drugInfo[@"gid"]
                              callback:^(id responseObject, NSError *error) {
                                  if (error) {
                                      [self showToastMessage:@"网络加载失败"];
                                      return ;
                                  }
                                  if (ServerSuccess(responseObject)) {
                                      [sender setImage:[UIImage imageNamed:@"collect_selected"]
                                              forState:UIControlStateNormal];
                                  } else {
                                      [self showToastMessage:responseObject[@"msg"]];
                                  }
                              }];
    }
}

#pragma mark - ImagePlayerViewDelegate
- (NSInteger)numberOfItems {
    return _imageURLStrings.count;
}

- (void)imagePlayerView:(ImagePlayerView *)imagePlayerView loadImageForImageView:(UIImageView *)imageView index:(NSInteger)index {
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [imageView sd_setImageWithURL:[NSURL URLWithString:_imageURLStrings[index]] placeholderImage:[UIImage imageNamed:@"defatul320"]];
}


#pragma mark - IBOutlets
- (IBAction)addShoppingCart:(id)sender {
    if (![YKSUserModel isLogin]) {
        [YKSTools login:self];
        return;
    }
    [self jumpAddCard];
//    if (![YKSUserModel shareInstance].addressLists) {
//        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main"
//                                                             bundle:[NSBundle mainBundle]];
//        YKSAddAddressVC *vc = [storyboard instantiateViewControllerWithIdentifier:@"YKSAddAddressVC"];
//        vc.callback = ^{
//            [self showProgress];
//            [GZBaseRequest addressListCallback:^(id responseObject, NSError *error) {
//                [self hideProgress];
//                if (error) {
//                    [self showToastMessage:@"网络加载失败"];
//                    return ;
//                }
//                if (ServerSuccess(responseObject)) {
//                    NSLog(@"responseObject = %@", responseObject);
//                    NSDictionary *dic = responseObject[@"data"];
//                    if ([dic isKindOfClass:[NSDictionary class]] && dic[@"addresslist"]) {
//                        [YKSUserModel shareInstance].addressLists = dic[@"addresslist"];
//                    }
//                } else {
//                    [self showToastMessage:responseObject[@"msg"]];
//                }
//            }];
//        };
//        [self.navigationController pushViewController:vc animated:YES];
//        return ;
//    }
//
    
    
    
    }

- (IBAction)butAction:(id)sender {
    
    
    /*
    if (![YKSUserModel isLogin]) {
        [YKSTools login:self];
        return;
    }
    
    if (![YKSUserModel shareInstance].addressLists) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main"
                                                             bundle:[NSBundle mainBundle]];
        YKSAddAddressVC *vc = [storyboard instantiateViewControllerWithIdentifier:@"YKSAddAddressVC"];
        vc.callback = ^{
            [self showProgress];
            [GZBaseRequest addressListCallback:^(id responseObject, NSError *error) {
                [self hideProgress];
                if (error) {
                    [self showToastMessage:@"网络加载失败"];
                    return ;
                }
                if (ServerSuccess(responseObject)) {
                    NSLog(@"responseObject = %@", responseObject);
                    NSDictionary *dic = responseObject[@"data"];
                    if ([dic isKindOfClass:[NSDictionary class]] && dic[@"addresslist"]) {
                        [YKSUserModel shareInstance].addressLists = dic[@"addresslist"];
                    }
                } else {
                    [self showToastMessage:responseObject[@"msg"]];
                }
            }];
        };
        [self.navigationController pushViewController:vc animated:YES];
        return ;
    }
    
    //这里已经加载网络.拉倒当前地址了
    
    
    if (![YKSUserModel shareInstance].currentSelectAddress) {
        //如果地址不存在,sb中找到地址地址列表vc
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main"
                                                             bundle:[NSBundle mainBundle]];
        YKSAddressListViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"YKSAddressListViewController"];
        //vc的一个回调属性 输入当前地址字典
        vc.callback = ^(NSDictionary *info){
            [YKSUserModel shareInstance].currentSelectAddress = info;
        };
        
        //当前的导航控制器,直接push那个vc,到地址列表vc
        [self.navigationController pushViewController:vc animated:YES];
        return ;
    }
    
    //如果地址存在,则跳购买
    [self performSegueWithIdentifier:@"gotoYKSSingleBuyViewController" sender:_drugInfo];
     */
    [self jumpSeque];
  }

- (void)jumpSeque
{
    //这里已经加载网络.拉倒当前地址了
    NSDictionary *currentAddr = [UIViewController selectedAddressUnArchiver];
    
    //显示判断登陆没有,请登陆
    if (![YKSUserModel isLogin]) {
        [self showToastMessage:@"请登陆"];
        [YKSTools login:self];
        return;
    }
    
    
    //如果列表为空,什么地址都没有,去添加地址控制器
    if (!currentAddr[@"express_mobilephone"]) {
        //这里要默认点击那个地址button所以也要加记录
        //默认让点击这个地址列表
        [UIViewController selectedAddressButtonArchiver:1];
//        self.tabBarController.selectedIndex = 0;
        
//        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main"
//                                                             bundle:[NSBundle mainBundle]];
//        YKSAddressListViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"YKSAddressListViewController"];
//        vc.callback = ^(NSDictionary *info){
//            
//            [YKSUserModel shareInstance].currentSelectAddress = info;
//            
//        };
//        
//        [self.navigationController pushViewController:vc animated:YES];

        [self showAddressView];
        
       // [self.navigationController popToRootViewControllerAnimated:NO];
        return;
    }

    //不支持配送
    if ([currentAddr[@"sendable"] integerValue] == 0) {
        [self showToastMessage:@"暂不支持配送您选择的区域，我们会尽快开通"];
        return;
    }
    
    //号码不为空,能送达
    if (currentAddr[@"express_mobilephone"] && ([currentAddr[@"sendable"] integerValue] != 0)) {
        [self performSegueWithIdentifier:@"gotoYKSSingleBuyViewController" sender:currentAddr];
    }
    
    
    //如果地址列表不为空,但是没有选择的地址,跳去首页自己选择地址
    
    //如果地址不可送达,那么弹框提示
    
    //如果可以地址有效,可送达,直接跳购买

}

- (void)jumpAddCard
{
    //这里已经加载网络.拉倒当前地址了
    NSDictionary *currentAddr = [UIViewController selectedAddressUnArchiver];
    
    //显示判断登陆没有,请登陆
    if (![YKSUserModel isLogin]) {
        [self showToastMessage:@"请登陆"];
        [YKSTools login:self];
        return;
    }
    
    
    //如果列表为空,什么地址都没有,去添加地址控制器
    if (!currentAddr[@"express_mobilephone"]) {
        //这里要默认点击那个地址button所以也要加记录
        //默认让点击这个地址列表
//        [UIViewController selectedAddressButtonArchiver:1];
//        self.tabBarController.selectedIndex = 0;
//        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main"
//                                                             bundle:[NSBundle mainBundle]];
//        YKSAddressListViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"YKSAddressListViewController"];
//        vc.callback = ^(NSDictionary *info){
//            
//            [YKSUserModel shareInstance].currentSelectAddress = info;
//            
//        };
//        [self.navigationController pushViewController:vc animated:YES];
        
        [self showAddressView];
        return;
    }
    
    
    //不支持配送
    if ([currentAddr[@"sendable"] integerValue] == 0) {
        [self showToastMessage:@"暂不支持配送您选择的区域，我们会尽快开通"];
        return;
    }
    
    
    //号码不为空,能送达
    if (currentAddr[@"express_mobilephone"] && ([currentAddr[@"sendable"] integerValue] != 0)) {
        
        
        
        if (![YKSUserModel shareInstance].currentSelectAddress) {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main"
                                                                 bundle:[NSBundle mainBundle]];
            YKSAddressListViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"YKSAddressListViewController"];
            vc.callback = ^(NSDictionary *info){
                [YKSUserModel shareInstance].currentSelectAddress = info;
            };
            [self.navigationController pushViewController:vc animated:YES];
            return ;
        }
        
        
        [self showProgress];
        
        NSDictionary *dic = @{@"gid": _drugInfo[@"gid"],
                              @"gcount": @(1),
                              @"gtag": _drugInfo[@"gtag"],
                              @"banners": _drugInfo[@"banners"],
                              @"gtitle": _drugInfo[@"gtitle"],
                              @"gprice": _drugInfo[@"gprice"],
                              @"gpricemart": _drugInfo[@"gpricemart"],
                              @"glogo": _drugInfo[@"glogo"],
                              @"gdec": _drugInfo[@"gdec"],
                              @"purchase": _drugInfo[@"purchase"],
                              @"gstandard": _drugInfo[@"gstandard"],
                              @"vendor": _drugInfo[@"vendor"],
                              @"iscollect": _drugInfo[@"iscollect"],
                              @"gmanual": _drugInfo[@"gmanual"]
                              };
        
        
        [GZBaseRequest addToShoppingcartParams:@[dic]
                                          gids:_drugInfo[@"gid"]
                                      callback:^(id responseObject, NSError *error) {
                                          [self hideProgress];
                                          if (error) {
                                              [self showToastMessage:@"网络加载失败"];
                                              return ;
                                          }
                                          if (ServerSuccess(responseObject)) {
                                              [self showToastMessage:@"加入购物车成功"];
                                              self.shoppingCartButton.selected = YES;
                                          } else {
                                              [self showToastMessage:responseObject[@"msg"]];
                                          }
                                      }];
        
    }
    
    
}

- (IBAction)shoppingCartAction:(id)sender {
    if (![YKSUserModel isLogin]) {
        [YKSTools login:self];
        return;
    }
    
    self.shoppingCartButton.selected = NO;
    [self performSegueWithIdentifier:@"gotoShoppingCart" sender:nil];
}


#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return 90.0f;
    } else if (indexPath.row == 1) {
        return [tableView fd_heightForCellWithIdentifier:@"drugActionCell" configuration:^(YKSDrugActionCell *actionCell) {
            actionCell.actionLabel.text = _drugInfo[@"gdec"];
        }];
    } else if (indexPath.row == 2) {
        return [tableView fd_heightForCellWithIdentifier:@"drugDescribeCell" configuration:^(YKSDrugDescribeCell *describeCell) {
            
            describeCell.directionLabel.text =DefuseNUllString(_drugInfo[@"drugstore"][@"address"]);//DefuseNUllString(_drugInfo[@"gmanual"]);
        }];
    }
    return 40.0f;
}



#pragma mark - UITableViewDatasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    YKSDrugInfoCell *cell;
    if (indexPath.row == 0) {
        YKSDrugNameCell *nameCell = [tableView dequeueReusableCellWithIdentifier:@"drugNameCell" forIndexPath:indexPath];
        nameCell.nameLabel.text = DefuseNUllString(_drugInfo[@"gtitle"]);
//        NSString *priceString = [NSString stringWithFormat:@"￥%0.2f /盒", [_drugInfo[@"gprice"] floatValue]];

        NSString *priceString = [NSString stringWithFormat:@"￥%0.2f  ", [_drugInfo[@"gprice"] floatValue]];
        
        NSMutableAttributedString *attribuedString = [[NSMutableAttributedString alloc] initWithString:priceString];
        [attribuedString addAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:15.0],
                                         NSForegroundColorAttributeName: (id)UIColorFromRGB(0xE81728)}
                                 range:NSMakeRange(0, 1)];
        [attribuedString addAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:19.0],
                                         NSForegroundColorAttributeName: (id)UIColorFromRGB(0xE81728)}
                                 range:NSMakeRange(1, priceString.length - 4)];
        [attribuedString addAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:13.0],
                                         NSForegroundColorAttributeName: [UIColor darkGrayColor]}
                                 range:NSMakeRange(priceString.length - 2, 2)];
        nameCell.priceLabel.attributedText = attribuedString;
        
        NSString *originPrice = [NSString stringWithFormat:@"原价：￥%0.2f", [_drugInfo[@"gpricemart"] floatValue]];
        attribuedString = [[NSMutableAttributedString alloc] initWithString:originPrice attributes:@{NSStrikethroughStyleAttributeName: @(NSUnderlineStyleNone)}];
        [attribuedString addAttributes:@{NSStrikethroughStyleAttributeName: @(NSUnderlineStyleSingle)}
                                 range:NSMakeRange(4, originPrice.length - 4)];
        nameCell.originPriceLabel.attributedText = attribuedString;
        
        
        if ([_drugInfo[@"iscollect"] boolValue]) {
            [nameCell.collectButton setImage:[UIImage imageNamed:@"collect_selected"] forState:UIControlStateNormal];
        }
        [nameCell.collectButton addTarget:self action:@selector(collectAction:) forControlEvents:UIControlEventTouchUpInside];
        cell = nameCell;
        
    } else if (indexPath.row == 1) {
        YKSDrugActionCell *actionCell = [tableView dequeueReusableCellWithIdentifier:@"drugActionCell" forIndexPath:indexPath];
        actionCell.actionLabel.text = DefuseNUllString(_drugInfo[@"gdec"]);
        cell = actionCell;
        
    } else if (indexPath.row  == 2) {
        YKSDrugDescribeCell *describeCell = [tableView dequeueReusableCellWithIdentifier:@"drugDescribeCell" forIndexPath:indexPath];
        describeCell.factoryLabel.text = DefuseNUllString(_drugInfo[@"vendor"]);
        describeCell.directionLabel.text =@"" ; //DefuseNUllString(_drugInfo[@"gmanual"]);  DefuseNUllString(_drugInfo[@"drugstore"][@"address"])
        describeCell.drugStoreNameLable.text=DefuseNUllString(_drugInfo[@"drugstore"][@"name"]);
        
        cell = describeCell;
    }
    return cell;
}


- (IBAction)gotoShouMing:(id)sender {
    
    
  
    YKSDrugShuoMingViewController *shuoMing=[[YKSDrugShuoMingViewController alloc]init];
    
    shuoMing.shuoMingDic = _drugInfo;

    
    [self.navigationController pushViewController:shuoMing animated:YES];
   
}


 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"gotoYKSSingleBuyViewController"]) {
        YKSSingleBuyViewController *singleVC = segue.destinationViewController;
        singleVC.drugInfo = _drugInfo;
        
    }
//    else if ([segue.identifier isEqualToString:@"YKSDrugShuoMingViewController"])
//    {
//        YKSDrugShuoMingViewController *DrugVC = segue.destinationViewController;
//       DrugVC.shuoMingDic = _drugInfo;
//        
//    }
}




//显示地址
- (void)showAddressView {
    
    // 不允许
    if (![YKSUserModel isLogin]) {
        [YKSTools login:self];
        return ;
    }
    __weak id bself = self;
    YKSSelectAddressView *selectAddressView = nil;
    
    YKSMyAddressViewcontroller *myVC=[[YKSMyAddressViewcontroller alloc]init];
    
    myVC.hidesBottomBarWhenPushed=YES;
    
    [self.navigationController pushViewController:myVC animated:YES];
    
    selectAddressView = [YKSSelectAddressView showAddressViewToView:myVC.view
                                                              datas:@[[self currentAddressInfo]]
                                                           callback:^(NSDictionary *info, BOOL isCreate) {
                                                               //新添
                                                               self.info=info;
                                                               
                                                               self.isCreat=isCreate;
                                                               
                                                               [UIViewController selectedAddressArchiver:info];
                                                               
                                                               if (![[[YKSUserModel shareInstance]currentSelectAddress][@"id"]isEqualToString:info[@"id"]]) {
                                                                   UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"修改地址？" message:@"确认修改地址将清空购物车" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                                                                   [alert show];
                                                                   return ;
                                                                   //                                                              [alert callBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                                                   //                                                                  if (buttonIndex == 1) {
                                                                   //
                                                                   //                                                                  }
                                                                   //                                                              }];
                                                               }
                                                               if (info) {
                                                                   if (info[@"community_lat_lng"]) {
                                                                       NSArray *array = [info[@"community_lat_lng"] componentsSeparatedByString:@","];
                                                                       [YKSUserModel shareInstance].lat = [[array firstObject] floatValue];
                                                                       [YKSUserModel shareInstance].lng = [[array lastObject] floatValue];
                                                                   }
                                                                   if (![YKSUserModel shareInstance].currentSelectAddress) {
                                                                       [YKSUserModel shareInstance].currentSelectAddress = info;
                                                                   }
                                                                   
                                                               }
                                                               if (isCreate) {
                                                                   
                                                                   
                                                                   [bself gotoAddressVC:info];
                                                               } else {
                                                                   
                                                                   [YKSUserModel shareInstance].currentSelectAddress = info;
                                                                   //这里就是了,拿到地址,删除旧地址
                                                                   
                                                                   [UIViewController deleteFile];           [UIViewController selectedAddressArchiver:info];
                                                                   
                                                                
                                                                   
                                                               }
                                                           }];
    //    [selectAddressView reloadData];
    selectAddressView.removeViewCallBack = ^{
        

    };
    [GZBaseRequest addressListCallback:^(id responseObject, NSError *error) {
        if (ServerSuccess(responseObject)) {
            NSDictionary *dic = responseObject[@"data"];
            if ([dic isKindOfClass:[NSDictionary class]] && dic[@"addresslist"]) {
                selectAddressView.datas = [dic[@"addresslist"] mutableCopy];
                [YKSUserModel shareInstance].addressLists = selectAddressView.datas;
                if (!selectAddressView.datas) {
                    selectAddressView.datas = [NSMutableArray array];
                }
                
                [selectAddressView.datas insertObject:[self currentAddressInfo] atIndex:0];
                [selectAddressView reloadData];
            }
        }
    }];
    
}

- (NSDictionary *)currentAddressInfo {
    
    NSDictionary *dic=[UIViewController selectedMyLocation];
    
    NSString *district = dic[@"addressComponent"][@"district"];
    NSString *street = dic[@"addressComponent"][@"street"];
    NSString *street_number = dic[@"addressComponent"][@"street_number"];
    NSString *formatted_address = dic[@"formatted_address"];
    
    
    NSString  *a=(NSString *)dic[@"sendable"];
    if (IS_EMPTY_STRING(a)) {
        return @{@"province": @"11",
                 @"district": district ? district : @"",
                 @"street":  street ? street : @"",
                 @"street_number":  street_number ? street_number : @"",
                 @"express_username": @"我的位置",
                 @"express_mobilephone": @"",
                 @"express_detail_address":  formatted_address? formatted_address : @""
                 };
    }
    
    return @{@"province": @"11",
             @"district": district ? district : @"",
             @"street":  street ? street : @"",
             @"street_number":  street_number ? street_number : @"",
             @"express_username": @"我的位置",
             @"express_mobilephone": @"",
             @"express_detail_address":  formatted_address? formatted_address : @"",
             @"sendable":a
             };
}


- (void)gotoAddressVC:(NSDictionary *)addressInfo {
   
    if (![YKSUserModel isLogin]) {
        [YKSTools login:self];
        return;
    }
    
    UIStoryboard *mainBoard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    YKSAddAddressVC *vc = [mainBoard instantiateViewControllerWithIdentifier:@"YKSAddAddressVC"];
    vc.addressInfo = [addressInfo mutableCopy];
    vc.isCurrentLocation = YES;
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex==1) {
        __weak id bself = self;
        YKSSelectAddressView *selectAddressView = nil;
        {
            //新添
            NSDictionary *info = self.info;
            BOOL isCreate = self.isCreat;
            if (info) {
                if (info[@"community_lat_lng"]) {
                    NSArray *array = [info[@"community_lat_lng"] componentsSeparatedByString:@","];
                    [YKSUserModel shareInstance].lat = [[array firstObject] floatValue];
                    [YKSUserModel shareInstance].lng = [[array lastObject] floatValue];
                }
            }
            if (isCreate) {
                [bself gotoAddressVC:[UIViewController selectedMyLocation]];
                
                return;
            } else {
                [YKSUserModel shareInstance].currentSelectAddress = info;
                //这里就是了,拿到地址,删除旧地址
                
                [UIViewController deleteFile];           [UIViewController selectedAddressArchiver:info];
                           }
        };
        //    [selectAddressView reloadData];
        selectAddressView.removeViewCallBack = ^{
            
        };
        [GZBaseRequest addressListCallback:^(id responseObject, NSError *error) {
            if (ServerSuccess(responseObject)) {
                NSDictionary *dic = responseObject[@"data"];
                if ([dic isKindOfClass:[NSDictionary class]] && dic[@"addresslist"]) {
                    selectAddressView.datas = [dic[@"addresslist"] mutableCopy];
                    [YKSUserModel shareInstance].addressLists = selectAddressView.datas;
                    if (!selectAddressView.datas) {
                        selectAddressView.datas = [NSMutableArray array];
                    }
                    [selectAddressView.datas insertObject:[self currentAddressInfo] atIndex:0];
                    [selectAddressView reloadData];
                }
            }
        }];
        
        [self.navigationController popToRootViewControllerAnimated:YES];
        
    }
    
    
    
    
}




@end
