//
//  AdvertiseViewController.m
//  SafaPPA
//
//  Created by Rawan Marzouq on 7/4/16.
//  Copyright © 2016 Rawan. All rights reserved.
//

#import "AdvertiseViewController.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>


@interface AdvertiseViewController ()<MFMailComposeViewControllerDelegate>

- (IBAction)CallButton:(id)sender;
- (IBAction)SendMail:(id)sender;
@end

@implementation AdvertiseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Set SAFA logo
    UIImageView *logo = [[UIImageView alloc]initWithFrame:CGRectMake(0,0, 30, 40)];
    logo.image = [UIImage imageNamed:@"logo-colored"];
    self.navigationItem.titleView = logo;
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

- (IBAction)CallButton:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"tel:+972599571417"]];
}

- (IBAction)SendMail:(id)sender {
    if([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mailCont = [[MFMailComposeViewController alloc] init];
        mailCont.mailComposeDelegate = self;
        [mailCont setToRecipients:[NSArray arrayWithObject:@"Adv@safa.ps"]];
        [mailCont setSubject:@"Your email"];
        [mailCont setMessageBody:[@"Your body for this message is " stringByAppendingString:@" this is awesome"] isHTML:NO];
        [self presentViewController:mailCont animated:YES completion:nil];
    }
}

// Then implement the delegate method
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    //handle any error
    [controller dismissViewControllerAnimated:YES completion:nil];
}
@end
