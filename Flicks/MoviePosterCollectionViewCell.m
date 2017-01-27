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
    __weak __typeof(self) weakSelf = self;
    NSURLRequest *imageRequest = [NSURLRequest requestWithURL:self.model.imageUrl];
    [self.imageView setImageWithURLRequest:imageRequest
                            placeholderImage:nil
                                     success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull image) {
                                         // imageResponse will be nil if the image is cached
                                         if (response != nil) {
                                             NSLog(@"Image was NOT cached, fade in image");
                                             weakSelf.imageView.alpha = 0.0;
                                             weakSelf.imageView.image = image;
                                             [UIView animateWithDuration:0.3 animations:^{
                                                 weakSelf.imageView.alpha = 1.0;
                                             }];
                                         }
                                         else
                                         {
                                             NSLog(@"Image was cached so just update the image");
                                             weakSelf.imageView.image = image;
                                         }
                                         
                                     } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {
                                         nil;
                                     }];
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.imageView.frame = self.contentView.bounds;
}

@end
