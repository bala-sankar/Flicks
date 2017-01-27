//
//  MovieModel.m
//  Flicks
//
//  Created by Balachandar Sankar on 1/23/17.
//  Copyright © 2017 Balachandar Sankar. All rights reserved.
//

#import "MovieModel.h"

@implementation MovieModel

-(instancetype) initWithDictionary:(NSDictionary *)otherDictionary {
    self = [super init];
    if (self) {
        self.title = otherDictionary[@"original_title"];
        self.movieDescription = otherDictionary[@"overview"];
        NSString *url = [NSString stringWithFormat:@"https://image.tmdb.org/t/p/original%@", otherDictionary[@"poster_path"]];
        self.imageUrl = [NSURL URLWithString:url];
    }
    return self;
}

@end
