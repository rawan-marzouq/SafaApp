//
//  MediaDetailsViewController.m
//  SafaPPA
//
//  Created by Rawan Marzouq on 7/21/16.
//  Copyright © 2016 Rawan. All rights reserved.
//

#import "MediaDetailsViewController.h"

@interface MediaDetailsViewController ()<UIWebViewDelegate>

- (IBAction)Back:(id)sender;
@end

@implementation MediaDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
-(void)viewDidAppear:(BOOL)animated{
    NSLog(@"_postLink: %@",_postLink);
    [self.mediaWeb loadHTMLString:_postLink baseURL:nil];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)Back:(id)sender {
    NSLog(@"Back");
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
