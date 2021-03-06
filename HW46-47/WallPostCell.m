//
//  WallPostCell.m
//  (lesson45)APITest
//
//  Created by Илья Егоров on 27.06.16.
//  Copyright © 2016 Илья Егоров. All rights reserved.
//

#import "WallPostCell.h"
#import "WallPost.h"
#import "User.h"

#import "ServerManager.h"

@interface WallPostCell ()

@property (weak, nonatomic) IBOutlet UILabel* postTextLabel;
@property (weak, nonatomic) IBOutlet UILabel* dateLabel;
@property (weak, nonatomic) IBOutlet UILabel* commentsLabel;

@end

@implementation WallPostCell

-(void)setPost:(WallPost *)post {
    _post = post;
    
    [self.postTextLabel setText:post.text];
    [self.commentsLabel setText:post.commentsNumber];
    [self.dateLabel setText:post.date];
    
    [self.likesButton setTitle:post.likesNumber forState:UIControlStateNormal];
    [self.likesButton setTitle:post.likesNumber forState:UIControlStateSelected];
    [self.likesButton setTitle:post.likesNumber forState:UIControlStateHighlighted];
}

-(void)setUser:(User*)user {
    _user = user;
    [self.userInfoLabel setText:[NSString stringWithFormat:@"%@ %@", user.firstName, user.lastName]];
}

-(IBAction)userDidClickLike:(id)sender {
    
    if (!self.delegate) {
        return;
    }
    [self.delegate changedLikeToWallPost:self.post.wallPostID];
}

-(void)awakeFromNib {
    
    [self.likesButton.layer setCornerRadius:4.f];
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc]
                                             initWithTarget:self action:@selector(actionClickImage)];
    self.avatarImageView.userInteractionEnabled = YES;
    [self.avatarImageView addGestureRecognizer:tapRecognizer];
}

-(void)actionClickImage {
    [self.delegate shouldPostMessage:self];
}

+ (CGFloat) heightForText:(NSString *)text {
    
    CGFloat offset = 9.f;
    
    UIFont* font = [UIFont systemFontOfSize:16.f];
    
    NSShadow* shadow = [[NSShadow alloc] init];
    [shadow setShadowOffset:CGSizeMake(0, -1)];
    [shadow setShadowBlurRadius:0.5];
    
    NSMutableParagraphStyle* paragraph = [[NSMutableParagraphStyle alloc] init];
    [paragraph setLineBreakMode:NSLineBreakByWordWrapping];
    [paragraph setAlignment:NSTextAlignmentLeft];
    
    NSDictionary* attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                font, NSFontAttributeName,
                                paragraph, NSParagraphStyleAttributeName,
                                shadow, NSShadowAttributeName,  nil];
    
    CGRect rect = [text boundingRectWithSize:CGSizeMake([UIApplication sharedApplication].keyWindow.frame.size.width - 2 * offset, CGFLOAT_MAX)
                                     options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                  attributes:attributes
                                     context:nil];
    
    return 4*offset +  MAX(17 + 3 + CGRectGetHeight(rect) + 5 + 15, 53);
}
@end
