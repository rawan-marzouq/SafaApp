//
//  PrivecyPolicyViewController.m
//  SafaPPA
//
//  Created by Rawan Marzouq on 7/4/16.
//  Copyright © 2016 Rawan. All rights reserved.
//

#import "PrivecyPolicyViewController.h"

@interface PrivecyPolicyViewController ()
@property (weak, nonatomic) IBOutlet UITextView *policyTextView;

@end

@implementation PrivecyPolicyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Set SAFA logo
    UIImageView *logo = [[UIImageView alloc]initWithFrame:CGRectMake(0,0, 30, 40)];
    logo.image = [UIImage imageNamed:@"logo-colored"];
    self.navigationItem.titleView = logo;
    
    self.policyTextView.scrollEnabled = YES;
    [self.policyTextView setContentOffset:CGPointZero animated:NO];
    self.automaticallyAdjustsScrollViewInsets = false;
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
