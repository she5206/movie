//
//  MovieCell.m
//  movie
//
//  Created by Man-Chun Hsieh on 6/14/15.
//  Copyright (c) 2015 Man-Chun Hsieh. All rights reserved.
//

#import "MovieCell.h"

@implementation MovieCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) prepareForReuse{
    [super prepareForReuse];
    self.poster.image = nil;
}

@end
