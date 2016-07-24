//
//  WallPostViewController.m
//  HW46-47
//
//  Created by Илья Егоров on 17.07.16.
//  Copyright © 2016 Ilya Egorov. All rights reserved.
//

#import "WallPostViewController.h"
#import "WallPostCell.h"
#import "CommentTableViewCell.h"
#import "WallPost.h"
#import "Comment.h"
#import "User.h"
#import "ServerManager.h"
#import "WriteMessageViewController.h"

#import "UIImageView+AFNetworking.h"

@interface WallPostViewController () <WallPostCellDelegate, CommentCellDelegate>

@property (strong, nonatomic) NSMutableArray* commentsArray;
@property (assign, nonatomic) BOOL reachedMaximum;

@end

static NSInteger postsInRequest = 10;
static NSString* groupId = @"58860049";

@implementation WallPostViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"WallPostCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"wallPostCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"CommentTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"commentCell"];
    
    UIRefreshControl* refresh = [[UIRefreshControl alloc] init];
    [refresh addTarget:self action:@selector(refreshComments) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;
    
    UIBarButtonItem* plus = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(shouldPostMessage:)];
    
    [self.navigationItem setRightBarButtonItem:plus];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshComments) name:@"shouldRefreshPosts" object:nil];
    
    self.commentsArray = [NSMutableArray array];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setWallPost:(WallPost *)wallPost {
    _wallPost = wallPost;
    [self getCommentsFromServer];
}

#pragma mark - API


-(void)shouldPostMessage:(id)sender {
    
    WriteMessageViewController* wmvc;
    if ([sender isKindOfClass:[WallPostCell class]]) {
        wmvc = [[WriteMessageViewController alloc] initWithUser:((WallPostCell*)sender).user];
    } else {
        wmvc = [[WriteMessageViewController alloc] initWithWallPost:self.wallPost];
    }
    
    UIViewController* mainVC = [[[[UIApplication sharedApplication] windows] firstObject] rootViewController];
    mainVC.providesPresentationContextTransitionStyle = YES;
    mainVC.definesPresentationContext = YES;
    [wmvc setModalPresentationStyle:UIModalPresentationOverCurrentContext];
    [mainVC presentViewController:wmvc animated:YES completion:nil];
}


-(void)refreshComments {
    
    if (!self.refreshControl.isRefreshing) {
        [self.refreshControl beginRefreshing];
    }
    self.reachedMaximum = NO;
    [[ServerManager sharedManager]
     getCommentsForWallPost:self.wallPost.wallPostID
     ofCommunity:groupId
     withOffset:0
     andCount:MAX(postsInRequest, [self.commentsArray count])
     onSuccess:^(NSArray *comments) {
         
         [self.commentsArray removeAllObjects];
         
         [self.commentsArray addObjectsFromArray:comments];
         
         if (comments.count < postsInRequest) {
             self.reachedMaximum = YES;
         }
         
         [self.tableView reloadData];
         
         [self.refreshControl endRefreshing];
         
     } onFailure:^(NSError *error, NSInteger statusCode) {
         
         NSLog(@"error = %@, code = %d", [error localizedDescription], statusCode);
         
         [self.refreshControl endRefreshing];
         
     }];
}

-(void)getCommentsFromServer {
    
    [[ServerManager sharedManager]
     getCommentsForWallPost:self.wallPost.wallPostID
     ofCommunity:groupId
     withOffset:[self.commentsArray count]
     andCount:postsInRequest
     onSuccess:^(NSArray *comments) {
         
         if (comments.count) {
             [self.commentsArray addObjectsFromArray:comments];
             [self.tableView reloadData];

         }
         
    } onFailure:^(NSError *error, NSInteger statusCode) {
        
         NSLog(@"error = %@, code = %d", [error localizedDescription], statusCode);
        
    }];
}

-(void)changedLikeToWallPost:(NSString*)wallPostId {
    
    [[ServerManager sharedManager] isLikedObjectOfType:@"post" withId:wallPostId ofCommunity:groupId onSuccess:^(BOOL isLiked) {
        
        if (isLiked) {
            [[ServerManager sharedManager] deleteLikesFromObjectWithType:@"post" withId:wallPostId ofCommunity:groupId onSuccess:^(NSDictionary *likes) {
                [self.wallPost setLikesNumber:[NSString stringWithFormat:@"%@ likes", [[likes objectForKey:@"likes"] stringValue]]];
                [self.tableView reloadData];
            } onFailure:^(NSError *error, NSInteger statusCode) {
                
            }];
        } else {
            [[ServerManager sharedManager] addLikesToObjectOfType:@"post" withId:wallPostId ofCommunity:groupId onSuccess:^(NSDictionary *likes) {
                [self.wallPost setLikesNumber:[NSString stringWithFormat:@"%@ likes", [[likes objectForKey:@"likes"] stringValue]]];
                [self.tableView reloadData];
            } onFailure:^(NSError *error, NSInteger statusCode) {
                
            }];
        }
        
    } onFailure:^(NSError *error, NSInteger statusCode) {
        
    }];
}


-(void)addLikeToComment:(NSString *)commentId {
    [[ServerManager sharedManager] addLikesToObjectOfType:@"comment" withId:commentId ofCommunity:groupId onSuccess:^(NSDictionary *likes) {
        for (Comment* comment in self.commentsArray) {
            if ([comment.commentID isEqualToString:commentId]) {
                [comment setLikesNumber:[NSString stringWithFormat:@"%@ likes", [[likes objectForKey:@"likes"] stringValue]]];
                [comment setUserLikes:YES];
                [self.tableView reloadData];
                break;
            }
        }
        
    } onFailure:^(NSError *error, NSInteger statusCode) {
        
    }];
}

-(void)removeLikeFromComment:(NSString *)commentId {
    [[ServerManager sharedManager] deleteLikesFromObjectWithType:@"comment" withId:commentId ofCommunity:groupId onSuccess:^(NSDictionary *likes) {
        for (Comment* comment in self.commentsArray) {
            if ([comment.commentID isEqualToString:commentId]) {
                [comment setLikesNumber:[NSString stringWithFormat:@"%@ likes", [[likes objectForKey:@"likes"] stringValue]]];
                [comment setUserLikes:NO];
                [self.tableView reloadData];
                break;
            }
        }
    } onFailure:^(NSError *error, NSInteger statusCode) {
        
    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return 1 + [self.commentsArray count] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        static NSString* identifier = @"wallPostCell";
        
        WallPostCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
        
        [cell setDelegate:self];
        
        [cell setBackgroundColor:[UIColor colorWithWhite:0.96 alpha:1.f]];
        
        WallPost* post = self.wallPost;
        
        [cell setPost:post];
        
        [[ServerManager sharedManager] isLikedObjectOfType:@"post" withId:post.wallPostID ofCommunity:groupId onSuccess:^(BOOL isLiked) {
            
            CGFloat alpha = isLiked ? 0.87:0.34;
            
            [cell.likesButton setBackgroundColor:[UIColor colorWithRed:0 green:122/256.f blue:1.f alpha:alpha]];
            
        } onFailure:^(NSError *error, NSInteger statusCode) {
            
        }];
        
        
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

    } else if (indexPath.row == [self.commentsArray count] + 1) {
        
        static NSString* identifier = @"Cell";
        
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
        
        cell.textLabel.text = @"Load More";
        cell.imageView.image = nil;
        
        return cell;
        
    } else {
        
        static NSString* identifier = @"commentCell";
        
        CommentTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
        
        [cell setDelegate:self];
        
        Comment* comment = [self.commentsArray objectAtIndex:indexPath.row - 1];
        
        [cell setComment:comment];
        
        NSString* authorID = comment.fromUserID;
        
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
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == [self.commentsArray count] + 1) {
        return 44.f;
    } else if (indexPath.row == 0) {
        return [WallPostCell heightForText:self.wallPost.text];
    } else {
        Comment* comment = [self.commentsArray objectAtIndex:indexPath.row - 1];
        return [CommentTableViewCell heightForText:comment.text];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
