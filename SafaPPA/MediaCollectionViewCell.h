//
//  MediaCollectionViewCell.h
//  SafaPPA
//
//  Created by Rawan Marzouq on 7/20/16.
//  Copyright © 2016 Rawan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MediaCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *mediaImage;

@end
