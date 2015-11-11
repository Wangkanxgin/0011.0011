//
//  YKSMyViewController.m
//  YueKangSong
//
//  Created by gongliang on 15/5/16.
//  Copyright (c) 2015年 YKS. All rights reserved.
//

#import "YKSMyViewController.h"
#import "YKSUserModel.h" 
#import "YKSHomeTableViewController.h"
@interface YKSMyViewController ()

@property (weak, nonatomic) IBOutlet UILabel *myCenterTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *myCenterLabel;

@end

@implementation YKSMyViewController



- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if ([YKSUserModel isLogin]) {
        _myCenterTitleLabel.text = [YKSUserModel telePhone];
        _myCenterLabel.text = @"个人信息中心";
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    } else {
        _myCenterTitleLabel.text = @"注册/登录";
        _myCenterLabel.text = @"";
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (IBAction)msgAction:(id)sender {
    if (![YKSUserModel isLogin]) {
        [self performSegueWithIdentifier:@"gotoLogin" sender:nil];
        return ;
    }
    
    [self performSegueWithIdentifier:@"gotoYKSMsgTableViewController" sender:nil];
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (![YKSUserModel isLogin] && !(indexPath.section == 4||(indexPath.section==3&&indexPath.row==1))) {
        [self performSegueWithIdentifier:@"gotoLogin" sender:nil];
        return ;
    }
    
    if (indexPath.section == 0) {
        [self performSegueWithIdentifier:@"gotoYKSMyInfoDetailVC" sender:nil];
    } else if (indexPath.section == 1) {
        switch (indexPath.row) {
            case 0: {
                [self performSegueWithIdentifier:@"gotoOrderVC" sender:nil];
            }
                break;
            case 1: {
                [self performSegueWithIdentifier:@"gotoCollectVC" sender:nil];
            }
                break;
            case 2: {
                [self performSegueWithIdentifier:@"gotoCouponVC" sender:nil];
            }
                break;
            case 3: {
                [self performSegueWithIdentifier:@"gotoAddressVC" sender:nil];
            }
                break;
            default:
                break;
        }
    }else if (indexPath.section == 2){
        [self performSegueWithIdentifier:@"yaoqingma" sender:nil];
    }
    else if (indexPath.section == 3) {
        switch (indexPath.row) {
            case 0: {
                if (![YKSUserModel isLogin]) {
                    [self performSegueWithIdentifier:@"gotoLogin" sender:nil];
                    return ;
                }
                [self performSegueWithIdentifier:@"gotoYKSFeedbackViewController" sender:nil];
            }
                break;
            case 1:
                [self performSegueWithIdentifier:@"gotoYKSAboutViewController" sender:nil];
                break;
            default:
                break;
        }
//    }else if (indexPath.section == 4){
//        if ([YKSUserModel isLogin]) {
//            [YKSUserModel logout];
//            YKSHomeTableViewController *homevc = [self.storyboard instantiateViewControllerWithIdentifier:@"YKSHomeTableViewController" ];
//            [homevc.addressButton setTitle:@"我的位置" forState:UIControlStateNormal];
//            [self viewDidAppear:YES];
//        }

    }
}
//- (IBAction)tuiChuDengLu:(id)sender {
//    if ([YKSUserModel isLogin]) {
//        [YKSUserModel logout];
//        [self viewDidAppear:YES];
//
//    }
//    
//}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
