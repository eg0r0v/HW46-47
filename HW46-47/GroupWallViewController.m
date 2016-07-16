//
//  GroupWallViewController.m
//  (lesson45)APITest
//
//  Created by Илья Егоров on 27.06.16.
//  Copyright © 2016 Илья Егоров. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GroupWallViewController.h"
#import "WriteMessageViewController.h"
#import "ServerManager.h"

#import "UIImageView+AFNetworking.h"

#import "WallPostCell.h"

#import "User.h"
#import "Group.h"
#import "WallPost.h"

@interface GroupWallViewController () <WallPostCellDelegate>

@property (strong, nonatomic) Group* currentGroup;
@property (strong, nonatomic) User* currentUser;
@property (strong, nonatomic) NSMutableArray* postsArray;
@property (assign, nonatomic) BOOL firstTimeAppear;

@end

static NSInteger postsInRequest = 10;
static NSString* groupId = @"58860049";

@implementation GroupWallViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.firstTimeAppear = YES;
    self.postsArray =  [NSMutableArray array];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    
    UIRefreshControl* refresh = [[UIRefreshControl alloc] init];
    [refresh addTarget:self action:@selector(refreshWall) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;
    
    UIBarButtonItem* plus = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(shouldPostMessage:)];
    
    [self.navigationItem setRightBarButtonItem:plus];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshWall) name:@"shouldRefreshPosts" object:nil];
    
    [[ServerManager sharedManager] getGroup:groupId onSuccess:^(Group *group) {
        [self.navigationItem setTitle:group.groupName];
        self.currentGroup = group;
    } onFailure:^(NSError *error, NSInteger statusCode) {
        [self.navigationItem setTitle:@""];
    }];
    
    [[[self.tabBarController customizableViewControllers] firstObject].tabBarItem setImage:[self imageWithImage:[UIImage imageNamed:@"mac_client.png"] scaledToSize:CGSizeMake(30, 30)]];
    [[[self.tabBarController customizableViewControllers] lastObject].tabBarItem setImage:[self imageWithImage:[UIImage imageNamed:@"chat_filled.png"] scaledToSize:CGSizeMake(30, 30)]];
}

- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

-(void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    if (self.firstTimeAppear) {
        self.firstTimeAppear = NO;
        [[ServerManager sharedManager] authorizeUser:^(User *user) {
            
            NSLog(@"AUTHORIZED!");
            NSLog(@"%@ %@", user.firstName, user.lastName);
            
        }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - API

-(void)shouldPostMessage:(id)sender {
    
    WriteMessageViewController* wmvc;
    
    if ([sender isKindOfClass:[WallPostCell class]]) {
        wmvc = [[WriteMessageViewController alloc] initWithUser:((WallPostCell*)sender).user];
    } else {
        wmvc = [[WriteMessageViewController alloc] initWithGroup:self.currentGroup];
    }
    
    UIViewController* mainVC = [[[[UIApplication sharedApplication] windows] firstObject] rootViewController];
    mainVC.providesPresentationContextTransitionStyle = YES;
    mainVC.definesPresentationContext = YES;
    [wmvc setModalPresentationStyle:UIModalPresentationOverCurrentContext];
    [mainVC presentViewController:wmvc animated:YES completion:nil];
}

-(void)refreshWall {
    
    if (!self.refreshControl.isRefreshing) {
        [self.refreshControl beginRefreshing];
    }
    [[ServerManager sharedManager]
     getGroupWall:groupId
     withOffset:0 andCount:MAX(postsInRequest, [self.postsArray count])
     onSuccess:^(NSArray *posts) {
         
         [self.postsArray removeAllObjects];
         
         [self.postsArray addObjectsFromArray:posts];
         
         [self.tableView reloadData];
         
         [self.refreshControl endRefreshing];
         
     } onFailure:^(NSError *error, NSInteger statusCode) {
         
         NSLog(@"error = %@, code = %d", [error localizedDescription], statusCode);
         
         [self.refreshControl endRefreshing];
         
     }];
    
}

-(void)getPostsFromServer {
    
    [[ServerManager sharedManager]
     getGroupWall:groupId
     withOffset:[self.postsArray count] andCount:postsInRequest
     onSuccess:^(NSArray *posts) {
         
         [self.postsArray addObjectsFromArray:posts];
         
          NSMutableArray* newPaths = [NSMutableArray array];

          for (int i = (int)[self.postsArray count] - (int)[posts count]; i < (int)[self.postsArray count]; i++) {
              [newPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
          }

          [self.tableView beginUpdates];
          [self.tableView insertRowsAtIndexPaths:newPaths withRowAnimation:UITableViewRowAnimationTop];
          [self.tableView endUpdates];
         
     } onFailure:^(NSError *error, NSInteger statusCode) {
         
         NSLog(@"error = %@, code = %d", [error localizedDescription], statusCode);
         
     }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return [self.postsArray count] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == [self.postsArray count]) {
        
        static NSString* identifier = @"Cell";
        
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
        
        cell.textLabel.text = @"Load More";
        cell.imageView.image = nil;
        
        return cell;
        
    } else {
        
        static NSString* identifier = @"wallPostCell";
        
        WallPostCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
        [cell setDelegate:self];
        
        WallPost* post = [self.postsArray objectAtIndex:indexPath.row];
        [cell setPost:post];
        
        NSString* authorID = post.fromUserID;
        
        [[ServerManager sharedManager] getUser:authorID onSuccess:^(User *user) {
            
            [cell setUser:user];
            dispatch_async(dispatch_get_main_queue(), ^{
                
                __weak UIImageView* weakCellImage = cell.avatarImageView;
                
                [cell.avatarImageView
                 setImageWithURLRequest:[NSURLRequest requestWithURL:user.imageURL]
                 placeholderImage:nil
                 success:^void(NSURLRequest * __nonnull request, NSHTTPURLResponse * __nonnull responce, UIImage * __nonnull image) {
                     weakCellImage.image = image;
                     [cell setNeedsLayout];
                 } failure:^ void(NSURLRequest * __nonnull request,
                                  NSHTTPURLResponse * __nonnull responce,
                                  NSError * __nonnull error) {
                 }];

            });
        } onFailure:^(NSError *error, NSInteger statusCode) {}];
        
        return cell;

    }
}

#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == [self.postsArray count]) {
        [self getPostsFromServer];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == [self.postsArray count]) {
        return 44.f;
    } else {
        
        WallPost* post = [self.postsArray objectAtIndex:indexPath.row];
        return [WallPostCell heightForText:post.text];
        
    }
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == [self.postsArray count]) {
        [self getPostsFromServer];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
