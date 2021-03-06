//
//  MovieDetailsViewController.m
//  Flicks
//
//  Created by Balachandar Sankar on 1/25/17.
//  Copyright © 2017 Balachandar Sankar. All rights reserved.
//

#import "MovieDetailsViewController.h"
#import <AFNetworking/UIImageView+AFNetworking.h>


@interface MovieDetailsViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *detailImage;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *cardView;
@property (weak, nonatomic) IBOutlet UILabel *descriptionCardLabel;

@end

@implementation MovieDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    __weak __typeof(self) weakSelf = self;
    NSURLRequest *imageRequest = [NSURLRequest requestWithURL:self.model.imageUrl];
    NSURLRequest *lowResImageRequest = [NSURLRequest requestWithURL:self.model.lowResImageUrl];
    [self.detailImage setImageWithURLRequest:lowResImageRequest
                          placeholderImage:nil
                                   success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull image) {
                                       NSLog(@"Image was NOT cached, fade in image");
                                       weakSelf.detailImage.alpha = 0.0;
                                       weakSelf.detailImage.image = image;
                                       [UIView animateWithDuration:0.3 animations:^{ weakSelf.detailImage.alpha = 1.0; }
                                                        completion:^(BOOL finished) {
                                                            [self.detailImage setImageWithURLRequest:imageRequest
                                                                       placeholderImage:image success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull hiResImage) {
                                                                           weakSelf.detailImage.image = hiResImage;
                                                                       } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {
                                                                           nil;
                                                                       }
                                                             ];
                                                        }
                                        ];
                                       
                                   } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {
                                       nil;
                                   }];
    
    self.descriptionCardLabel.text = self.model.movieDescription;
    [self.descriptionCardLabel sizeToFit];
    
    CGFloat xMargin = 48;
    CGFloat cardHeight = self.descriptionCardLabel.bounds.size.height + 120; // arbitrary value
    CGFloat bottomPadding = 24;
    CGFloat cardOffset = cardHeight * 0.25;
    self.scrollView.frame = CGRectMake(xMargin, // x
                                       CGRectGetHeight(self.view.bounds) - cardHeight - bottomPadding, // y
                                       CGRectGetWidth(self.view.bounds) - 2 * xMargin, // width
                                       cardHeight); // height
    
    self.cardView.frame = CGRectMake(0, cardOffset, CGRectGetWidth(self.scrollView.bounds), cardHeight);
    
    // content height is the height of the card plus the offset we want
    CGFloat contentHeight =  cardHeight + cardOffset;
    self.scrollView.contentSize = CGSizeMake(self.scrollView.bounds.size.width, contentHeight);

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

@end
