//
//  MovieModel.h
//  Flicks
//
//  Created by Balachandar Sankar on 1/23/17.
//  Copyright © 2017 Balachandar Sankar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MovieModel : NSObject

-(instancetype) initWithDictionary: (NSDictionary *) otherDictionary;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *movieDescription;
@property (nonatomic, strong) NSURL *imageUrl;
@property (nonatomic, strong) NSURL *lowResImageUrl;

@end
