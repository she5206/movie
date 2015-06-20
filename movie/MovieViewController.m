//
//  MovieViewController.m
//  movie
//
//  Created by Man-Chun Hsieh on 6/13/15.
//  Copyright (c) 2015 Man-Chun Hsieh. All rights reserved.
//

#import "MovieViewController.h"
#import "MovieCell.h"
#import "ViewController.h"
#import "UIImageView+AFNetworking.h"
#import "SVProgressHUD.h"
#import "Reachability.h"
#import <SystemConfiguration/SystemConfiguration.h>

@interface MovieViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>
{
    Reachability* internetReachable;
    Reachability* hostReachable;
}

@property (weak, nonatomic) IBOutlet UITableView *movieTable;
@property (strong, nonatomic) NSArray *movies;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (strong, nonatomic) UIView *headview;

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) NSArray *searchResult;

@end


@implementation MovieViewController
//NSArray *movies;
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [SVProgressHUD show];

    //[self.movieTable registerClass:[UITableViewCell class] forCellReuseIdentifier: @"MyMovieCell"]; // reuse
    self.movieTable.dataSource = self;
    self.movieTable.delegate = self;
    
    
    // load data form url
    [self loadDataFromUrl];
    
    // PULL refresh table view
    [self addRefreshViewController];
    
    // search bar
    [self addSearchBar];
}

- (void) loadDataFromUrl{
    NSString *url =@"http://api.rottentomatoes.com/api/public/v1.0/lists/movies/box_office.json?apikey=dagqdghwaq3e3mxyrp7kmmj5&limit=20&country=us";
    // establish a request
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    // get data from request url
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSDictionary *dict =[NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        self.movies = dict[@"movies"];
        [self.movieTable reloadData];
        self.searchResult = self.movies;
    }];
}

- (void)addSearchBar{
    [self.searchBar setPlaceholder:@"search"];
    self.searchBar.delegate = self;
    self.searchBar.showsCancelButton = YES;
    [self.view addSubview:self.searchBar];
}

//filter the movie when text input
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    self.movies = self.searchResult;
    NSMutableArray *temp = [[NSMutableArray alloc] init];
    for (int i =0; i< self.movies.count; i++) {
        if ([[((NSDictionary*)self.movies[i])[@"title"] lowercaseString] hasPrefix:[searchBar.text lowercaseString]]) {
            [temp addObject:self.movies[i]];
        }
    }
    self.movies = temp;
    temp = nil;
    
    if([searchBar.text isEqualToString:@""]){
        self.movies = self.searchResult;
    }
    [self.movieTable reloadData];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
     [self.view endEditing:YES];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    self.movies = self.searchResult;
    [self.movieTable reloadData];
    [self.view endEditing:YES];
    self.searchBar.text=@"";
}

- (void) addHeaderView {
    self.headview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.movieTable.frame.size.width, 25)];
    /* Create custom view to display section header... */
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, self.movieTable.frame.size.width, 22)];
    [label setFont:[UIFont boldSystemFontOfSize:12]];
    NSString *string =@"⚠️Networking Error";
    /* Section header is in 0th index... */
    [label setText:string];
    [self.headview addSubview:label];
    [self.headview setBackgroundColor:[UIColor colorWithRed:166/255.0 green:177/255.0 blue:186/255.0 alpha:1.0]]; //your background
    self.movieTable.tableHeaderView =self.headview;

}

- (BOOL)connected
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    return networkStatus != NotReachable;
}

-(void)addRefreshViewController{
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"下拉刷新"];
    [self.refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    [self.movieTable addSubview:self.refreshControl]; //把RefreshControl加到TableView中
}


-(void) refresh {
    if([self connected]){
        [self.refreshControl beginRefreshing];
        [self.movieTable reloadData];
        [self.refreshControl endRefreshing];
        self.movieTable.tableHeaderView = nil;
    }else{
        [self.refreshControl endRefreshing];
        [self addHeaderView];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];  //取消選取
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.movies.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    // reuse
    MovieCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyMovieCell" forIndexPath: indexPath];
    //cell.textLabel.text=[NSString stringWithFormat:@"Row %1d", indexPath.row];
    NSDictionary *movie = self.movies[indexPath.row];
    cell.titleLabel.text=movie[@"title"];
    cell.synopsisLabel.text=movie[@"synopsis"];
    NSString *imageURL= [movie valueForKeyPath:@"posters.thumbnail"];
    [cell.poster setImageWithURL:[NSURL URLWithString:imageURL]];
    
    //NSData *imageData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: imageURL]];
    //cell.poster.image = [UIImage imageWithData: imageData];
    [SVProgressHUD dismiss];
    return cell;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    MovieCell *cell = sender; // 轉型
    NSIndexPath *indexPath = [self.movieTable indexPathForCell:cell];
    NSDictionary *movie = self.movies[indexPath.row];
    ViewController *dest = segue.destinationViewController; //傳給下一頁
    dest.movie = movie;

}




@end
