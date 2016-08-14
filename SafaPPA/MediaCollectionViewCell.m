//
//  MediaCollectionViewCell.m
//  SafaPPA
//
//  Created by Rawan Marzouq on 7/20/16.
//  Copyright © 2016 Rawan. All rights reserved.
//

#import "MediaCollectionViewCell.h"

@implementation MediaCollectionViewCell

@synthesize titleLabel, mediaImage;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        // Initialization code
        NSArray *arrayOfViews = [[NSBundle mainBundle] loadNibNamed:@"MediaCell" owner:self options:nil];
        
        if ([arrayOfViews count] < 1) {
            return nil;
        }
        
        if (![[arrayOfViews objectAtIndex:0] isKindOfClass:[UICollectionViewCell class]]) {
            return nil;
        }
        
        self = [arrayOfViews objectAtIndex:0];
        
    }
    
    return self;
    
}
@end
