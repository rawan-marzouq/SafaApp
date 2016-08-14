//
//  MediaDetailsViewController.h
//  SafaPPA
//
//  Created by Rawan Marzouq on 7/21/16.
//  Copyright © 2016 Rawan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MediaDetailsViewController : UIViewController
@property(strong,nonatomic) NSString *postLink;
@property (weak, nonatomic) IBOutlet UIWebView *mediaWeb;

@end
