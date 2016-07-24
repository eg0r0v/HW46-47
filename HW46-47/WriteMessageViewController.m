//
//  WriteMessageViewController.m
//  HW46-47
//
//  Created by Илья Егоров on 04.07.16.
//  Copyright © 2016 Ilya Egorov. All rights reserved.
//

#import "WriteMessageViewController.h"
#import "ServerManager.h"
#import "Group.h"
#import "User.h"
#import "WallPost.h"

@interface WriteMessageViewController () <UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UIView* containerView;
@property (weak, nonatomic) IBOutlet UITextView* messageTextView;
@property (weak, nonatomic) IBOutlet UILabel* destinationIdName;
@property (weak, nonatomic) IBOutlet UIButton* sendMessageButton;
@property (strong, nonatomic) Group* groupToSend;
@property (strong, nonatomic) User* userToSend;
@property (strong, nonatomic) WallPost* wallPostToSend;

-(IBAction)actionClickedSend:(id)sender;

@end

static NSString* groupId = @"58860049";

@implementation WriteMessageViewController


-(void)viewDidLoad {
    [self.containerView.layer setCornerRadius:4.f];
    if (self.groupToSend) {
        [self.destinationIdName setText:self.groupToSend.groupName];
    } else if (self.userToSend) {
        [self.destinationIdName setText:[NSString stringWithFormat:@"%@ %@", self.userToSend.firstName, self.userToSend.lastName]];
    } else if (self.wallPostToSend) {
        [self.destinationIdName setText:@"Comment to post"];
    }
    
    [self.messageTextView setDelegate:self];
    [self.messageTextView.layer setBorderWidth:0.5f];
    [self.messageTextView.layer setBorderColor:[UIColor blackColor].CGColor];
    
    UITapGestureRecognizer *tapToDismiss = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapToDismiss:)];
    [self.view addGestureRecognizer:tapToDismiss];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
}

- (instancetype)initWithGroup:(Group *)groupToSend
{
    self = [super initWithNibName:@"WriteMessageViewController" bundle:[NSBundle mainBundle]];
    if (self) {
        self.groupToSend = groupToSend;
    }
    return self;
}

- (instancetype)initWithUser:(User *)userToSend
{
    self = [super initWithNibName:@"WriteMessageViewController" bundle:[NSBundle mainBundle]];
    if (self) {
        self.userToSend = userToSend;
    }
    return self;
}

- (instancetype)initWithWallPost:(WallPost *)wallPostToSend
{
    self = [super initWithNibName:@"WriteMessageViewController" bundle:[NSBundle mainBundle]];
    if (self) {
        self.wallPostToSend = wallPostToSend;
    }
    return self;
}

-(void)handleTapToDismiss:(UITapGestureRecognizer *)tap {
    if ([self.messageTextView isFirstResponder]) {
        [self.messageTextView resignFirstResponder];
    } else {
        CGRect alertFrame = [self.view convertRect:self.containerView.frame toView:nil];
        CGPoint tapLocation = [self.view convertPoint:[tap locationInView:self.view] toView:nil];
        if (!CGRectContainsPoint(alertFrame, tapLocation)) {
            [self.view endEditing:YES];
            self.wallPostToSend = nil;
            self.userToSend = nil;
            self.groupToSend = nil;
            [self dismissViewControllerAnimated:YES completion:^{
                
            }];
        }
    }
}

- (void)keyboardWasShown:(NSNotification*)notification {
    NSDictionary* info = [notification userInfo];
    CGFloat keyBoardOriginY = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].origin.y;
    self.messageTextView.contentInset = UIEdgeInsetsMake(0, 0, MAX(0, 73 + keyBoardOriginY - CGRectGetMaxX(self.messageTextView.frame)), 0);
    [self.messageTextView setNeedsLayout];
}

- (void)keyboardWillBeHidden:(NSNotification*)notification {
    self.messageTextView.contentInset = UIEdgeInsetsZero;
}


-(void)actionClickedSend:(id)sender {
    
    [self.sendMessageButton setUserInteractionEnabled:NO];
    if (self.messageTextView.text.length == 0) {
        return;
    }
    
    if (self.groupToSend) {
        [[ServerManager sharedManager] postText:self.messageTextView.text onGroupWall:self.groupToSend.groupID onSuccess:^(id result) {
            self.groupToSend = nil;
            [self dismissWithSuccess];
        } onFailure:^(NSError *error, NSInteger statusCode) {
            
        }];
    } else if (self.userToSend) {
        [[ServerManager sharedManager] sendText:self.messageTextView.text toUserId:self.userToSend.userID onSuccess:^{
            self.userToSend = nil;
            [self dismissWithSuccess];
        } onFailure:^(NSError *error, NSInteger statusCode) {
            
        }];
    } else if (self.wallPostToSend) {
        [[ServerManager sharedManager] sendText:self.messageTextView.text toWallPost:self.wallPostToSend.wallPostID onGroupWall:groupId onSuccess:^{
            self.wallPostToSend = nil;
            [self dismissWithSuccess];
        } onFailure:^(NSError *error, NSInteger statusCode) {
            
        }];
    }
}

-(void)dismissWithSuccess {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"shouldRefreshPosts" object:nil];
    [self.sendMessageButton setUserInteractionEnabled:YES];
    [self dismissViewControllerAnimated:YES completion:^{    }];
}


@end
