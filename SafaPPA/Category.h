//
//  Category.h
//  SafaPPA
//
//  Created by Rawan Marzouq on 7/9/16.
//  Copyright © 2016 Rawan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Category : NSObject
@property(assign) int categoryId;
@property(strong,nonatomic) NSString *categoryName;
@property(strong,nonatomic) NSString *categoryType;
@end
