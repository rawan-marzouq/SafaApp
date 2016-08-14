//
//  MediaViewController.m
//  SafaPPA
//
//  Created by Rawan Marzouq on 7/4/16.
//  Copyright © 2016 Rawan. All rights reserved.
//

#import "MediaViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "Post.h"
#import "MediaCollectionViewCell.h"
#import <MediaPlayer/MediaPlayer.h>
#import "MediaDetailsViewController.h"


@import AVFoundation;
@import AVKit;

@interface MediaViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIWebViewDelegate>
{
    NSMutableArray *categories;
    int catIndex;
    NSMutableArray *socials;
    NSMutableArray *posts;
    MPMoviePlayerController *moviePlayer;
    
}


@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loading;

// Main post elements
@property (weak, nonatomic) IBOutlet UIImageView *mainPostImage;
@property (weak, nonatomic) IBOutlet UILabel *mainPostTitle;
@property (weak, nonatomic) IBOutlet UILabel *mainPostDate;

@property (nonatomic, strong) IBOutlet UICollectionView *collectionView;

- (IBAction)ShowMainPostDetails:(id)sender;

@end

@implementation MediaViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    // Hide navigation bar
    self.navigationController.navigationBar.hidden = YES;
    
    // Collection view custom cell
    UINib *cellNib = [UINib nibWithNibName:@"MediaCell" bundle:nil];
    [self.collectionView registerNib:cellNib forCellWithReuseIdentifier:@"cell"];
    [self.collectionView registerClass:[MediaCollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    
    // Configure layout
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setItemSize:CGSizeMake(150, 150)];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    [self.collectionView setCollectionViewLayout:flowLayout];
}
-(void)viewDidAppear:(BOOL)animated{
    
    // Get media posts
    [self GetMediaPosts];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)ShowMainPostDetails:(id)sender {
    Post *selPost = (Post*)[posts objectAtIndex:0];
    NSString *videoURL = selPost.postLink;
    NSString *videoHTML = [NSString stringWithFormat:@"\
                           <html>\
                           <head>\
                           <style type=\"text/css\">\
                           iframe {position:absolute; top:50%%; margin-top:-130px;}\
                           body {background-color:#000; margin:0;}\
                           </style>\
                           </head>\
                           <body>\
                           <iframe width=\"100%%\" height=\"240px\" src=\"%@\" frameborder=\"0\" allowfullscreen></iframe>\
                           </body>\
                           </html>", videoURL];
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    MediaDetailsViewController *mediaVC = [sb instantiateViewControllerWithIdentifier:@"MediaDetails"];
    mediaVC.postLink = videoHTML;
    [self.navigationController presentViewController:mediaVC animated:YES completion:nil];
}

#pragma mark - REST Category's posts
-(void)GetMediaPosts{
    // Start loding
    self.loading.hidden = NO;
    
    
    posts = [[NSMutableArray alloc]init];
    
    // REST CALL
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://safa.ps/api/1.0/playlist"]];
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
            
            
            NSLog(@"Media: %@",jsonObjects);
            
            if (error) {
                NSLog(@"error is %@", [error localizedDescription]);
                // Handle Error and return
                return;
            }
            
            // Posts
            NSArray *postsData = [jsonObjects objectForKey:@"videos"];
            for (int i=0; i < [postsData count]; i++) {
                NSDictionary *post = (NSDictionary*) [postsData objectAtIndex:i];
                Post *postObj = [[Post alloc]init];
                postObj.postId = [[post objectForKey:@"id"] intValue];
                postObj.postTitle = [post objectForKey:@"name"];
                postObj.postImage = [post objectForKey:@"image"];
                postObj.postDate = [post objectForKey:@"created_at"];
                postObj.postLink = [post objectForKey:@"link"];
                [posts addObject:postObj];
            }
            // Set main post details
            Post *mainPost = (Post*)[posts objectAtIndex:0];
            
            NSAttributedString *attributedString = [[NSAttributedString alloc]
                                                    initWithData: [mainPost.postTitle dataUsingEncoding:NSUnicodeStringEncoding]
                                                    options: @{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType }
                                                    documentAttributes: nil
                                                    error: nil
                                                    ];
            self.mainPostTitle.attributedText = attributedString;
            self.mainPostTitle.textAlignment = NSTextAlignmentRight;
            self.mainPostTitle.font = [UIFont fontWithName:@"beIN-ArabicNormal" size:17];
            self.mainPostTitle.textColor = [UIColor whiteColor];
            self.mainPostDate.text = [self FormatDateToString:mainPost.postDate];
            self.mainPostDate.font = [UIFont fontWithName:@"beIN-ArabicNormal" size:13];
            self.mainPostImage.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://safa.ps/%@", mainPost.postImage]]]];
            
            // Reload posts table content
            [_collectionView reloadData];
            
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

#pragma mark - TableView Delegate & DataSource
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [posts count] - 1;
    
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    // Setup cell identifier
    static NSString *cellIdentifier = @"cell";
 
    MediaCollectionViewCell *cell = (MediaCollectionViewCell *)[self.collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    
    // Check if patients array is not null
    if ([posts count]) {
        Post *post = [posts objectAtIndex:indexPath.row + 1];
        // Show HTML String: Post title
        NSAttributedString *attributedString = [[NSAttributedString alloc]
                                                initWithData: [post.postTitle dataUsingEncoding:NSUnicodeStringEncoding]
                                                options: @{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType }
                                                documentAttributes: nil
                                                error: nil
                                                ];
        cell.titleLabel.attributedText = attributedString;
        cell.titleLabel.textAlignment = NSTextAlignmentRight;
        cell.titleLabel.font = [UIFont fontWithName:@"beIN-ArabicNormal" size:13];
        cell.titleLabel.textColor = [UIColor whiteColor];
        
        // Here we use the new provided sd_setImageWithURL: method to load the web image
        [cell.mediaImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://safa.ps/%@", post.postImage]] placeholderImage:[UIImage imageNamed:@"placeholder"] options:indexPath.row == 0 ? SDWebImageRefreshCached:0];
    }
    // Cell view configurations
    cell.backgroundColor = [UIColor clearColor];
    
    // Return the cell
    return cell;
    
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    Post *post = [posts objectAtIndex:indexPath.row + 1];
    NSLog(@"post.postLink: %@", post.postLink);

    NSString *videoURL = post.postLink;
    NSString *videoHTML = [NSString stringWithFormat:@"\
                           <html>\
                           <head>\
                           <style type=\"text/css\">\
                           iframe {position:absolute; top:50%%; margin-top:-130px;}\
                           body {background-color:#000; margin:0;}\
                           </style>\
                           </head>\
                           <body>\
                           <iframe width=\"100%%\" height=\"240px\" src=\"%@\" frameborder=\"0\" allowfullscreen></iframe>\
                           </body>\
                           </html>", videoURL];
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    MediaDetailsViewController *mediaVC = [sb instantiateViewControllerWithIdentifier:@"MediaDetails"];
    mediaVC.postLink = videoHTML;
    [self.navigationController presentViewController:mediaVC animated:YES completion:nil];
    
    
}



-(void)moviePlayBackDidFinish{
    NSLog(@"moviePlayBackDidFinish");
}
@end
