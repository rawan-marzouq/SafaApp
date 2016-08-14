//
//  Post.h
//  SafaPPA
//
//  Created by Rawan Marzouq on 7/9/16.
//  Copyright © 2016 Rawan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Post : NSObject
@property(assign) int postId;
@property(strong,nonatomic) NSString *postTitle;
@property(strong,nonatomic) NSString *postImage;
@property(strong,nonatomic) NSString *postDate;
@property(strong,nonatomic) NSString *postText;
@property(strong,nonatomic) NSString *postLink;
@end
