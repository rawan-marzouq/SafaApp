//
//  Social.h
//  SafaPPA
//
//  Created by Rawan Marzouq on 7/9/16.
//  Copyright © 2016 Rawan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Social : NSObject
@property(assign) int socialId;
@property(strong,nonatomic) NSString *socialName;
@property(strong,nonatomic) NSString *socialLink;
@end
