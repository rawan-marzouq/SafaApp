//
//  CellView.h
//  SafaPPA
//
//  Created by Rawan Marzouq on 7/11/16.
//  Copyright © 2016 Rawan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CellView : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *cellImage;
@property (weak, nonatomic) IBOutlet UILabel *cellTitle;
@property (weak, nonatomic) IBOutlet UILabel *cellSubTitle;

@end
