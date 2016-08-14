//
//  PostDetailsViewController.m
//  SafaPPA
//
//  Created by Rawan Marzouq on 7/12/16.
//  Copyright © 2016 Rawan. All rights reserved.
//

#import "PostDetailsViewController.h"

@interface PostDetailsViewController ()

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loading;

@property (weak, nonatomic) IBOutlet UILabel *postTitle;
@property (weak, nonatomic) IBOutlet UILabel *postDate;
@property (weak, nonatomic) IBOutlet UIImageView *postImage;
@property (weak, nonatomic) IBOutlet UITextView *postText;


- (IBAction)Back:(id)sender;
@end

@implementation PostDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [self GetPostDetailsForPost:self.post.postId];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - REST Category's posts
-(void)GetPostDetailsForPost:(int)postId{
    // Start loding
    self.loading.hidden = NO;
    
    NSLog(@"GetPostDetailsForPost:%i",postId);
    
    
    // REST CALL
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://safa.ps/api/1.0/post/%i",postId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"GET"];
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        // Handle response
        if (data.length > 0 && error == nil)
        {
            NSError *error = nil;
            id jsonObjects = [NSJSONSerialization JSONObjectWithData:data
                                                             options:NSJSONReadingMutableContainers
                                                               error:&error];
            
            
            NSLog(@"Details: %@",jsonObjects);
            
            if (error) {
                NSLog(@"error is %@", [error localizedDescription]);
                // Handle Error and return
                return;
            }
            
            // Posts
            NSArray *postsData = [jsonObjects objectForKey:@"posts"];
            Post *postObj = [[Post alloc]init];
            for (int i=0; i < [postsData count]; i++) {
                NSDictionary *post = (NSDictionary*) [postsData objectAtIndex:i];
                postObj.postId = [[post objectForKey:@"id"] intValue];
                postObj.postTitle = [post objectForKey:@"title"];
                postObj.postImage = [post objectForKey:@"image"];
                postObj.postDate = [post objectForKey:@"created_at"];
                postObj.postText = [post objectForKey:@"text"];
                
            }
            // Set post details
            // Show HTML String: Post title
            NSAttributedString *attributedString = [[NSAttributedString alloc]
                                                    initWithData: [postObj.postTitle dataUsingEncoding:NSUnicodeStringEncoding]
                                                    options: @{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType }
                                                    documentAttributes: nil
                                                    error: nil
                                                    ];
            self.postTitle.attributedText = attributedString;
            self.postTitle.textAlignment = NSTextAlignmentRight;
            self.postTitle.font = [UIFont fontWithName:@"beIN-ArabicNormal" size:17];
            self.postDate.text = [self FormatDateToString:postObj.postDate];
            self.postImage.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://safa.ps/%@", postObj.postImage]]]];
            // Show HTML String: Post text
            attributedString = [[NSAttributedString alloc]
                                                    initWithData: [postObj.postText dataUsingEncoding:NSUnicodeStringEncoding]
                                                    options: @{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType }
                                                    documentAttributes: nil
                                                    error: nil
                                                    ];
            self.postText.attributedText = attributedString;
            self.postText.textAlignment = NSTextAlignmentRight;
            self.postText.font = [UIFont fontWithName:@"beIN-ArabicThin" size:15];
            // Stop loding
            self.loading.hidden = YES;
        }
        else
        {
            // Handle Error
            UIAlertController *errorVC = [UIAlertController alertControllerWithTitle:@"Network Error" message:@"Please check your connection and try again" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            }];
            [errorVC addAction:okAction];
            [self presentViewController:errorVC animated:YES completion:nil];
            NSLog(@"Error: %@",error);
        }
    }];
    [dataTask resume];
}

#pragma mark - Format Date
-(NSString*)FormatDateToString:(NSString*)epochDate{
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *postDate = [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:[epochDate integerValue]]];
    return postDate;
}

- (IBAction)Back:(id)sender {
    NSLog(@"Back");
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
