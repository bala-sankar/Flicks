//
//  MovieTableViewCell.h
//  Flicks
//
//  Created by Balachandar Sankar on 1/23/17.
//  Copyright © 2017 Balachandar Sankar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MovieTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descLabel;
@property (weak, nonatomic) IBOutlet UIImageView *posterImage;

@end
