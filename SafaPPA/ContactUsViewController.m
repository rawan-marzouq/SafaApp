//
//  ContactUsViewController.m
//  SafaPPA
//
//  Created by Rawan Marzouq on 7/4/16.
//  Copyright © 2016 Rawan. All rights reserved.
//

#import "ContactUsViewController.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>


@interface ContactUsViewController ()<MFMailComposeViewControllerDelegate>
- (IBAction)ContactUsPressed:(id)sender;


@end

@implementation ContactUsViewController

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


- (IBAction)ContactUsPressed:(id)sender {
    if([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mailCont = [[MFMailComposeViewController alloc] init];
        mailCont.mailComposeDelegate = self;
        [mailCont setToRecipients:[NSArray arrayWithObject:@"edit@safa.ps"]];
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
