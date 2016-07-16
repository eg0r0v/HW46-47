//
//  ChatViewController.m
//  HW46-47
//
//  Created by Илья Егоров on 12.07.16.
//  Copyright © 2016 Ilya Egorov. All rights reserved.
//

#import "ChatViewController.h"
#import "ChatTableViewCell.h"
#import "WriteMessageViewController.h"
#import "ServerManager.h"
#import "MessageObject.h"
#import "User.h"

#import "UIImageView+AFNetworking.h"

@interface ChatViewController ()

@property (strong, nonatomic) User* user;
@property (strong, nonatomic) NSMutableArray * messagesArray;

@end

static NSInteger postsInRequest = 20;

@implementation ChatViewController

- (instancetype)initWithUser:(User *)user
{
    self = [super init];
    if (self) {
        self.user = user;
        [self getMoreMessages];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"ChatTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"chatCell"];

    self.messagesArray = [NSMutableArray array];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshMessages) name:@"shouldRefreshPosts" object:nil];
    
    UIBarButtonItem* plus = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(shouldPostMessage:)];
    
    [self.navigationItem setRightBarButtonItem:plus];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)getMoreMessages {
    [[ServerManager sharedManager]
     getMessagesWithId:self.user.userID
     WithOffset:[self.messagesArray count]
     andCount:postsInRequest onSuccess:^(NSArray *messages, long messagesNumber) {
     
         [self.navigationItem setTitle:[NSString stringWithFormat:@"%ld сообщений", messagesNumber]];
         [self.messagesArray addObjectsFromArray:messages];
         
         dispatch_async(dispatch_get_main_queue(), ^{
             [self.tableView reloadData];
         });
         
     } onFailure:^(NSError *error, NSInteger statusCode) {
     
     }];
}

-(void)shouldPostMessage:(id)sender {
    
    WriteMessageViewController* wmvc = [[WriteMessageViewController alloc] initWithUser:self.user];
    
    UIViewController* mainVC = [[[[UIApplication sharedApplication] windows] firstObject] rootViewController];
    mainVC.providesPresentationContextTransitionStyle = YES;
    mainVC.definesPresentationContext = YES;
    [wmvc setModalPresentationStyle:UIModalPresentationOverCurrentContext];
    [mainVC presentViewController:wmvc animated:YES completion:nil];
}

-(void)refreshMessages {

    if (!self.refreshControl.isRefreshing) {
        [self.refreshControl beginRefreshing];
    }
    [[ServerManager sharedManager] getMessagesWithId:self.user.userID WithOffset:0 andCount:postsInRequest onSuccess:^(NSArray *messages, long messagesNumber) {
        
        [self.navigationItem setTitle:[NSString stringWithFormat:@"%ld сообщений", messagesNumber]];
        [self.messagesArray removeAllObjects];
        [self.messagesArray addObjectsFromArray:messages];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            [self.refreshControl endRefreshing];
        });
        
    } onFailure:^(NSError *error, NSInteger statusCode) {
        
        NSLog(@"error = %@, code = %d", [error localizedDescription], statusCode);
        
        [self.refreshControl endRefreshing];
    }];
         
  
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.messagesArray.count + 1;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == [self.messagesArray count] && indexPath.row != 0) {
        [self getMoreMessages];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == [self.messagesArray count]) {
        
        static NSString* identifier = @"Cell";
        
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
        
        cell.textLabel.text = @"Load More";
        cell.imageView.image = nil;
        
        return cell;
    }
    
    ChatTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"chatCell" forIndexPath:indexPath];
    
    MessageObject* object = [self.messagesArray objectAtIndex:indexPath.row];
    
    if (cell.messageObject && [cell.messageObject.messageID isEqual:object.messageID]) {
        return cell;
    }
    
    [cell setMessageObject:object];
    
    NSString* authorID = [object.authorID stringValue];
    
    [[ServerManager sharedManager] getUser:authorID onSuccess:^(User *user) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [cell.userShortName setText: user.firstName];
            
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

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == [self.messagesArray count]) {
        return 44.f;
    } else {
        
        MessageObject* message = [self.messagesArray objectAtIndex:indexPath.row];
        return [ChatTableViewCell heightForText:message.body];
        
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


@end
