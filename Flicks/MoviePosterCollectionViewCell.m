//
//  MoviePosterCollectionViewCell.m
//  Flicks
//
//  Created by Balachandar Sankar on 1/26/17.
//  Copyright © 2017 Balachandar Sankar. All rights reserved.
//

#import "MoviePosterCollectionViewCell.h"
#import <AFNetworking/UIImageView+AFNetworking.h>


@interface MoviePosterCollectionViewCell ()

@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation MoviePosterCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.imageView = [UIImageView new];
        [self.contentView addSubview:self.imageView];
    }
    return self;
}

- (void)reloadData
{
    [self.imageView setImageWithURL:self.model.imageUrl];
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.imageView.frame = self.contentView.bounds;
}

@end
