//
//  ViewController.m
//  movie
//
//  Created by Man-Chun Hsieh on 6/12/15.
//  Copyright (c) 2015 Man-Chun Hsieh. All rights reserved.
//

#import "ViewController.h"
#import "UIImageView+AFNetworking.h"
@interface ViewController ()

@end

@implementation ViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleLabel.text = self.movie[@"title"];
    self.synopsisLabel.text = self.movie[@"synopsis"];
    NSString *posterURL=[self.movie valueForKeyPath:@"posters.detailed"];
    posterURL = [self convertPosterUrlStringToHighRes:posterURL];
    [self.poster setImageWithURL:[NSURL URLWithString:posterURL]];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString *) convertPosterUrlStringToHighRes:(NSString *)urlString{
    NSRange range = [urlString rangeOfString:@".*cloudfront.net/" options:NSRegularExpressionSearch];
    NSString *retrunValue = urlString;
    if(range.length>0){
        retrunValue = [urlString stringByReplacingCharactersInRange:range withString:@"https://content6.flixster.com/"];
    }
    return retrunValue;
}

@end
