//
//  ViewController.m
//  Flicks
//
//  Created by Balachandar Sankar on 1/23/17.
//  Copyright © 2017 Balachandar Sankar. All rights reserved.
//

#import "MovieListViewController.h"
#import "MovieTableViewCell.h"
#import "MovieModel.h"
#import "MovieDetailsViewController.h"
#import "MoviePosterCollectionViewCell.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import <AFNetworking/AFNetworkReachabilityManager.h>

typedef NS_ENUM(NSInteger, MovieListType) {
    MovieListTypeNowPlaying,
    MovieListTypeTopRated,
};

typedef NS_ENUM(NSInteger, MovieLayoutType) {
    MovieLayoutList,
    MovieLayoutGrid,
};

@interface MovieListViewController () <UITableViewDataSource, UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UITableView *movieTableView;
@property (strong, nonatomic) NSMutableArray<MovieModel *> *movieModels;
@property (strong, nonatomic) NSMutableArray<MovieModel *> *filteredMovies;
@property (nonatomic, assign) MovieListType type;
@property (nonatomic, assign) MovieLayoutType layoutType;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *layoutSegmentControl;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) UIRefreshControl *refreshControlForCollectionView;
@property (weak, nonatomic) IBOutlet UIView *networkErrorDialog;
@property (strong, nonatomic) AFNetworkReachabilityManager *networkingManager;
@property (weak, nonatomic) IBOutlet UISearchBar *searchMoviesBar;

@end

@implementation MovieListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.refreshControl = [UIRefreshControl new];
    self.refreshControlForCollectionView = [UIRefreshControl new];
    self.networkingManager = [AFNetworkReachabilityManager sharedManager];
    [self.refreshControl addTarget:self action:@selector(onRefresh) forControlEvents:UIControlEventValueChanged];
    [self.refreshControlForCollectionView addTarget:self action:@selector(onRefresh) forControlEvents:UIControlEventValueChanged];
    
    // Do any additional setup after loading the view, typically from a nib.
    self.movieTableView.dataSource = self;
    self.searchMoviesBar.delegate = self;
    self.movieModels = [NSMutableArray new];
    self.filteredMovies = [NSMutableArray new];
    static NSDictionary<NSString *, NSNumber *> *restorationIdentifierToTypeMapping;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        restorationIdentifierToTypeMapping = @{
                                               @"now_playing": @(MovieListTypeNowPlaying),
                                               @"top_rated": @(MovieListTypeTopRated),
                                               };
    });
    self.type = restorationIdentifierToTypeMapping[self.restorationIdentifier].integerValue;
    [self initCollectionView];
    [self fetchMovieDetails];
    [self.movieTableView insertSubview:self.refreshControl atIndex:0];
    [self.view bringSubviewToFront:self.networkErrorDialog];
    self.networkErrorDialog.hidden = YES;
}

-(void) initCollectionView {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    CGFloat screenWidth = CGRectGetWidth(self.view.bounds);
    CGFloat itemHeight = 150;
    CGFloat itemWidth = (screenWidth - 20) / 3;
    layout.minimumLineSpacing = 10;
    layout.minimumInteritemSpacing = 10;
    layout.itemSize = CGSizeMake(itemWidth, itemHeight);
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
    [collectionView registerClass:[MoviePosterCollectionViewCell class] forCellWithReuseIdentifier:@"MoviePosterCollectionViewCell"];
    collectionView.dataSource = self;
    collectionView.delegate = self;
    collectionView.backgroundColor = [UIColor whiteColor];

    [self.view addSubview:collectionView];
    self.collectionView = collectionView;
    [self.collectionView insertSubview:self.refreshControlForCollectionView atIndex:0];

    [self refreshLayout];
}

-(void) refreshLayout {
    switch (self.layoutType) {
        case MovieLayoutList:
            self.collectionView.hidden = YES;
            self.movieTableView.hidden = NO;
            break;
        case MovieLayoutGrid:
            self.collectionView.hidden = NO;
            self.movieTableView.hidden = YES;
            break;
    }
}

-(void) fetchMovieDetails {
    NSString *apiKey = @"a07e22bc18f5cb106bfe4cc1f83ad8ed";
    NSString *typePathComponent;
    switch (self.type) {
        case MovieListTypeNowPlaying:
            typePathComponent = @"now_playing";
            break;
        case MovieListTypeTopRated:
            typePathComponent = @"top_rated";
        break;
    }
    [self.networkingManager startMonitoring];
    
    NSString *urlString = [NSString stringWithFormat:@"https://api.themoviedb.org/3/movie/%@?api_key=%@", typePathComponent, apiKey];    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    
    NSURLSession *session =
    [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                                  delegate:nil
                             delegateQueue:[NSOperationQueue mainQueue]];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSLog(@"Going to make the request");
    [self.movieModels removeAllObjects];
    [self.filteredMovies removeAllObjects];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                            completionHandler:^(NSData * _Nullable data,
                                                                NSURLResponse * _Nullable response,
                                                                NSError * _Nullable error) {
                                                if (!error) {
                                                    NSError *jsonError = nil;
                                                    NSDictionary *responseDictionary =
                                                    [NSJSONSerialization JSONObjectWithData:data
                                                                                    options:kNilOptions
                                                                                      error:&jsonError];
//                                                    NSLog(@"Response: %@", responseDictionary);
                                                    NSArray *results = responseDictionary[@"results"];
                                                    for (NSDictionary *result in results) {
                                                        MovieModel *model = [[MovieModel alloc] initWithDictionary:result];
                                                        [self.movieModels addObject:model];
                                                        [self.filteredMovies addObject:model];
                                                    }
                                                    [self.movieTableView reloadData];
                                                    [self.collectionView reloadData];
                                                } else {
                                                    NSLog(@"An error occurred: %@", error.description);
                                                }
                                                [MBProgressHUD hideHUDForView:self.view animated:YES];
                                                if (self.networkingManager.reachable) {
                                                    self.networkErrorDialog.hidden = YES;
                                                } else {
                                                    self.networkErrorDialog.hidden = NO;
                                                }

                                            }];
    [self.networkingManager stopMonitoring];
    [task resume];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.filteredMovies.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MovieTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"movieCell" forIndexPath:indexPath];
    MovieModel *model = [self.filteredMovies objectAtIndex:indexPath.row];
    [cell.titleLabel setText:model.title];
    cell.descLabel.text = model.movieDescription;
    
    NSURLRequest *imageRequest = [NSURLRequest requestWithURL:model.imageUrl];
    [cell.posterImage setImageWithURLRequest:imageRequest
                            placeholderImage:nil
                                     success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull image) {
                                         // imageResponse will be nil if the image is cached
                                         if (response != nil) {
                                             NSLog(@"Image was NOT cached, fade in image");
                                             cell.posterImage.alpha = 0.0;
                                             cell.posterImage.image = image;
                                             [UIView animateWithDuration:0.3 animations:^{
                                                 cell.posterImage.alpha = 1.0;
                                             }];
                                         }
                                         else
                                         {
                                             NSLog(@"Image was cached so just update the image");
                                             cell.posterImage.image = image;
                                         }

                                     } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {
                                         nil;
                                     }];
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    MovieDetailsViewController *detailsController = [segue destinationViewController];
    
    NSIndexPath *indexPath = [NSIndexPath new];
    if([sender isKindOfClass:[MovieTableViewCell class]]) {
        indexPath = [self.movieTableView indexPathForCell:sender];
        detailsController.model = [self.filteredMovies objectAtIndex:indexPath.row];
    } else {
        indexPath = sender;
        detailsController.model = [self.movieModels objectAtIndex:indexPath.item];
    }
    [self.view endEditing:YES];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return (self.movieModels.count / 3) * 3;
}


- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MoviePosterCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MoviePosterCollectionViewCell" forIndexPath:indexPath];
    MovieModel *model = [self.movieModels objectAtIndex:indexPath.item];
    
    cell.model = model;
    [cell reloadData];
    return cell;
}

- (IBAction)onValueChanged:(UISegmentedControl *)sender {
    self.layoutType = self.layoutSegmentControl.selectedSegmentIndex;
    [self refreshLayout];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.collectionView.frame = self.view.bounds;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"showDetailSegue" sender:indexPath];
}

- (void)onRefresh {
    [self fetchMovieDetails];
    [self.refreshControl endRefreshing];
    [self.refreshControlForCollectionView endRefreshing];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self.filteredMovies removeAllObjects];
    if (![searchText isEqualToString:@""]) {
        for (MovieModel *model in self.movieModels) {
            if([model.title containsString:searchText]){
                [self.filteredMovies addObject:model];
            }
        }
    } else {
        for (MovieModel *model in self.movieModels) {
            [self.filteredMovies addObject:model];
        }
        [self.view endEditing:YES];
    }
    
    [self.movieTableView reloadData];
}


@end
