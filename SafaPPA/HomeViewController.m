//
//  HomeViewController.m
//  SafaPPA
//
//  Created by Rawan Marzouq on 7/4/16.
//  Copyright © 2016 Rawan. All rights reserved.
//

#import "HomeViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "PostDetailsViewController.h"
#import "CellView.h"
#import "Category.h"
#import "Social.h"
#import "Post.h"

@interface HomeViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    NSMutableArray *categories;
    int catIndex;
    NSMutableArray *socials;
    NSMutableArray *posts;
}
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loading;
// Header elements @ actions
@property (weak, nonatomic) IBOutlet UILabel *headerTitle;
- (IBAction)NextCategory:(id)sender;
- (IBAction)PrevCategory:(id)sender;
- (IBAction)SearchButton:(id)sender;

// Main post elements
@property (weak, nonatomic) IBOutlet UIImageView *mainPostImage;
@property (weak, nonatomic) IBOutlet UILabel *mainPostTitle;
@property (weak, nonatomic) IBOutlet UILabel *mainPostDate;
@property (weak, nonatomic) IBOutlet UITableView *postsTable;
- (IBAction)ShowMainPostDetails:(id)sender;

// Social buttons
- (IBAction)Facebook:(id)sender;
- (IBAction)Twitter:(id)sender;
- (IBAction)Instagram:(id)sender;
- (IBAction)Youtube:(id)sender;
@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Hide navigation bar
    self.navigationController.navigationBar.hidden = YES;
    
    // Set category index to 0 (main)
    catIndex = -1;NSLog(@"catIndex: %i",catIndex + 1);
    
    [self GetHomeData];
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

#pragma mark - REST Home Data

-(void)GetHomeData{
    // Start loding
    self.loading.hidden = NO;
    
    // Initialies categories, socials, posts array
    categories = [[NSMutableArray alloc]init];
    socials = [[NSMutableArray alloc]init];
    posts = [[NSMutableArray alloc]init];
    
    // REST CALL
    NSURL *url = [NSURL URLWithString:@"http://safa.ps/api/1.0/home"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"GET"];
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        // Handle response
        if (data.length > 0 && error == nil)
        {
            NSError *error = nil; NSLog(@"data: %@",response);
            id jsonObjects = [NSJSONSerialization JSONObjectWithData:data
                                                             options:kNilOptions
                                                               error:&error];
            
            NSLog(@"home: %@",jsonObjects);
            
            if (error) {
                NSLog(@"error is %@", [error localizedDescription]);
                // Handle Error and return
                return;
            }
            
            // Categories
            NSArray *categoriesData = [jsonObjects objectForKey:@"categories"];
            for (int i=0; i < [categoriesData count]; i++) {
                NSDictionary *cat = (NSDictionary*) [categoriesData objectAtIndex:i];
                Category *catObj = [[Category alloc]init];
                catObj.categoryId = [[cat objectForKey:@"id"] intValue];
                catObj.categoryName = [cat objectForKey:@"name"];
                catObj.categoryType = [cat objectForKey:@"type"];
                [categories addObject:catObj];
            }
            Category *categoryObj = (Category*)[categories objectAtIndex:0];
            [self GetPostsForCategory:categoryObj.categoryId];
            
//            // Social
//            NSArray *socialData = [jsonObjects objectForKey:@"social"];
//            for (int i=0; i < [socialData count]; i++) {
//                NSDictionary *social = (NSDictionary*) [socialData objectAtIndex:i];
//                Social *socialObj = [[Social alloc]init];
//                socialObj.socialId = [[social objectForKey:@"id"] intValue];
//                socialObj.socialName = [social objectForKey:@"name"];
//                socialObj.socialLink = [social objectForKey:@"link"];
//                [socials addObject:socialObj];
//            }
//            Social *sObj = (Social*)[socials objectAtIndex:4];
//            NSLog(@"%@",sObj.socialName);
            
            // Posts
            NSArray *postsData = [jsonObjects objectForKey:@"posts"];
            for (int i=0; i < [postsData count]; i++) {
                NSDictionary *post = (NSDictionary*) [postsData objectAtIndex:i];
                Post *postObj = [[Post alloc]init];
                postObj.postId = [[post objectForKey:@"id"] intValue];
                postObj.postTitle = [post objectForKey:@"title"];
                postObj.postImage = [post objectForKey:@"image"];
                postObj.postDate = [post objectForKey:@"created_at"];
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
            self.mainPostImage.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://safa.ps/%@", mainPost.postImage]]]];
            
            // Reload posts table content
            [_postsTable reloadData];
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
//-(void)GetCategories{
//    
//    // Initialies categories array
//    categories = [[NSMutableArray alloc]init];
//    
//    // REST CALL
//    NSURL *url = [NSURL URLWithString:@"http://safa.ps/api/1.0/categories"];
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
//    [request setHTTPMethod:@"GET"];
//    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
//    NSURLSession *session = [NSURLSession sessionWithConfiguration:config delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
//    
//    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
//        // Handle response
//        if (data.length > 0 && error == nil)
//        {
//            NSError *error = nil;
//            id jsonObjects = [NSJSONSerialization JSONObjectWithData:data
//                                                             options:NSJSONReadingMutableContainers
//                                                               error:&error];
//            
//            
//            NSLog(@"CATEGORUES: %@",jsonObjects);
//            
//            if (error) {
//                NSLog(@"error is %@", [error localizedDescription]);
//                // Handle Error and return
//                return;
//            }
//            NSArray *categoriesData = [jsonObjects objectForKey:@"categories"];
//            for (int i=0; i < [categoriesData count]; i++) {
//                NSDictionary *cat = (NSDictionary*) [categoriesData objectAtIndex:i];
//                Category *catObj = [[Category alloc]init];
//                catObj.categoryId = [[cat objectForKey:@"id"] intValue];
//                catObj.categoryName = [cat objectForKey:@"name"];
//                catObj.categoryType = [cat objectForKey:@"type"];
//                [categories addObject:catObj];
//            }
//            Category *categoryObj = (Category*)[categories objectAtIndex:0];
//            [self GetPostsForCategory:categoryObj.categoryId];
//        }
//        else
//        {
//            // Handle Error
//            UIAlertController *errorVC = [UIAlertController alertControllerWithTitle:@"Network Error" message:@"Please check your connection and try again" preferredStyle:UIAlertControllerStyleAlert];
//            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
//            }];
//            [errorVC addAction:okAction];
//            [self presentViewController:errorVC animated:YES completion:nil];
//            NSLog(@"Error: %@",error);
//        }
//    }];
//    [dataTask resume];
//}
#pragma mark - REST Category's posts
-(void)GetPostsForCategory:(int)categoryId{
    // Start loding
    self.loading.hidden = NO;
    
    NSLog(@"GetPostsForCategory:%i",categoryId);
    
    posts = [[NSMutableArray alloc]init];
    
    // REST CALL
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://safa.ps/api/1.0/posts/%i",categoryId]];
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
            
            
            NSLog(@"Category: %@",jsonObjects);
            
            if (error) {
                NSLog(@"error is %@", [error localizedDescription]);
                // Handle Error and return
                return;
            }
            
            // Posts
            NSArray *postsData = [jsonObjects objectForKey:@"posts"];
            for (int i=0; i < [postsData count]; i++) {
                NSDictionary *post = (NSDictionary*) [postsData objectAtIndex:i];
                Post *postObj = [[Post alloc]init];
                postObj.postId = [[post objectForKey:@"id"] intValue];
                postObj.postTitle = [post objectForKey:@"title"];
                postObj.postImage = [post objectForKey:@"image"];
                postObj.postDate = [post objectForKey:@"created_at"];
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
            [_postsTable reloadData];
            
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
#pragma mark - Social Buttons
- (IBAction)Facebook:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"https://www.facebook.com/safaps"]];
}

- (IBAction)Twitter:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"https://twitter.com/safaps"]];
}

- (IBAction)Instagram:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"http://www.instagram.com/safappa"]];
}
- (IBAction)Youtube:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"http://www.youtube.com/user/safappa"]];
}

#pragma mark - TableView Delegate & DataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [posts count] - 1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 101;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *MyIdentifier = @"MyIdentifier";
    
    CellView *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    if (cell == nil) {
        [tableView registerNib:[UINib nibWithNibName:@"CellView" bundle:nil] forCellReuseIdentifier:MyIdentifier];
        cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    }
    
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
        cell.cellTitle.attributedText = attributedString;
        cell.cellTitle.textAlignment = NSTextAlignmentRight;
        cell.cellTitle.font = [UIFont fontWithName:@"beIN-ArabicNormal" size:15];
//        cell.cellTitle.text = [NSString stringWithFormat:@"%@",post.postTitle];
        cell.cellSubTitle.text = [NSString stringWithFormat:@"%@",[self FormatDateToString:post.postDate]];
        
        // Here we use the new provided sd_setImageWithURL: method to load the web image
        [cell.cellImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://safa.ps/%@", post.postImage]] placeholderImage:[UIImage imageNamed:@"placeholder"] options:indexPath.row == 0 ? SDWebImageRefreshCached:0];
    }
    // Cell view configurations
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    Post *selPost = (Post*)[posts objectAtIndex:indexPath.row + 1];
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    PostDetailsViewController *postVC = [sb instantiateViewControllerWithIdentifier:@"PostDetails"];
    postVC.post = selPost;
    [self.navigationController presentViewController:postVC animated:YES completion:nil];
}
#pragma mark - Header categories buttons
- (IBAction)NextCategory:(id)sender {
    if (catIndex < [categories count] - 1) {
        catIndex +=1;
        

    }
    else if (catIndex == -1){
        catIndex = 0;
    }
    else{
        catIndex = -1;
        self.headerTitle.text = @"الرئيسية";
        [self GetHomeData];
        return;
    }
    // Set title
    Category *currCat = (Category *)[categories objectAtIndex:catIndex];
    self.headerTitle.text = currCat.categoryName;
    
    // Get posts
    [self GetPostsForCategory:currCat.categoryId];
    NSLog(@"Next currCat: %@, catIndex: %i", self.headerTitle.text, catIndex);
}

- (IBAction)PrevCategory:(id)sender {
    if (catIndex == 0) {
        catIndex =  -1;
        self.headerTitle.text = @"الرئيسية";
        [self GetHomeData];
        return;
    }
    else if(catIndex < 0){
        catIndex = [categories count] - 1;
    }
    else{
        catIndex -= 1;
    }
    // Set title
    Category *currCat = (Category *)[categories objectAtIndex:catIndex];
    self.headerTitle.text = currCat.categoryName;
    
    // Get posts
    [self GetPostsForCategory:currCat.categoryId];
    NSLog(@"Prev currCat: %@, catIndex: %i", currCat.categoryName, catIndex);
}

- (IBAction)SearchButton:(id)sender {
}
- (IBAction)ShowMainPostDetails:(id)sender {
    Post *selPost = (Post*)[posts objectAtIndex:0];
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    PostDetailsViewController *postVC = [sb instantiateViewControllerWithIdentifier:@"PostDetails"];
    postVC.post = selPost;
    [self.navigationController presentViewController:postVC animated:YES completion:nil];
}
@end
