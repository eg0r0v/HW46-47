//
//  HistoryViewController.m
//  HW46-47
//
//  Created by Илья Егоров on 09.07.16.
//  Copyright © 2016 Ilya Egorov. All rights reserved.
//

#import "HistoryViewController.h"
#import "HistoryTableViewCell.h"
#import "HistoryObject.h"
#import "ServerManager.h"
#import "User.h"

#import "ChatViewController.h"

#import "UIImageView+AFNetworking.h"


@interface HistoryViewController ()

@property (strong, nonatomic) NSMutableArray* dialogsArray;

@end

static NSInteger postsInRequest = 10;

@implementation HistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];

    
    UIRefreshControl* refresh = [[UIRefreshControl alloc] init];
    [refresh addTarget:self action:@selector(refreshMessages) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;
    
    
    self.dialogsArray =  [NSMutableArray array];
    
    [self getMoreHistory];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)refreshMessages {
    
    if (!self.refreshControl.isRefreshing) {
        [self.refreshControl beginRefreshing];
    }
    [[ServerManager sharedManager]
     getMessageHistoryWithOffset:0 andCount:MAX(postsInRequest, [self.dialogsArray count]) andPreviewLength:100 onSuccess:^(NSArray *dialogs, long dialogsNumber) {
        [self.dialogsArray removeAllObjects];
        
        [self.dialogsArray addObjectsFromArray:dialogs];
        
        [self.tableView reloadData];
        
        [self.refreshControl endRefreshing];

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
    return [self.dialogsArray count] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == [self.dialogsArray count]) {
        
        static NSString* identifier = @"Cell";
        
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
        
        cell.textLabel.text = @"Load More";
        cell.imageView.image = nil;
        
        return cell;
    }
    
    HistoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"historyCell" forIndexPath:indexPath];
    
    HistoryObject* object = [self.dialogsArray objectAtIndex:indexPath.row];
    
    if (cell.historyObject && [cell.historyObject.messageID isEqual:object.messageID]) {
        return cell;
    }
    
    [cell.avatarImageView setImage:nil];
    [cell.userNameLabel setText:@""];
    [cell.messagePreviewLabel setText:@""];
    
    [cell setHistoryObject:object];
    
    NSString* authorID = object.authorID;
    
    [[ServerManager sharedManager] getUser:authorID onSuccess:^(User *user) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [cell.userNameLabel setText:[NSString stringWithFormat:@"%@ %@", user.firstName, user.lastName]];
            
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

-(void)getMoreHistory {
    [[ServerManager sharedManager] getMessageHistoryWithOffset:[self.dialogsArray count] andCount:postsInRequest andPreviewLength:100 onSuccess:^(NSArray *dialogsArray, long dialogsCount) {
        
        [self.navigationItem setTitle:[NSString stringWithFormat:@"%ld диалогов", dialogsCount]];
        [self.dialogsArray addObjectsFromArray:dialogsArray];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
        
    } onFailure:^(NSError *error, NSInteger statusCode) {
        
    }];

}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == [self.dialogsArray count] && indexPath.row != 0) {
        [self getMoreHistory];
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    HistoryObject* selectedObject = [self.dialogsArray objectAtIndex:indexPath.row];
    
    [[ServerManager sharedManager] getUser:selectedObject.authorID onSuccess:^(User *user) {
        
        ChatViewController* cvc = [[ChatViewController alloc] initWithUser:user];
        [self.navigationController pushViewController:cvc animated:YES];
        
    } onFailure:^(NSError *error, NSInteger statusCode) {
        
    }];
    
    
   
}

@end
