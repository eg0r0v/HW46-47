//
//  CommentTableViewCell.m
//  HW46-47
//
//  Created by Илья Егоров on 19.07.16.
//  Copyright © 2016 Ilya Egorov. All rights reserved.
//

#import "CommentTableViewCell.h"
#import "Comment.h"
#import "User.h"

@interface CommentTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *userInfoLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@property (weak, nonatomic) IBOutlet UIButton *likesButton;

@end

@implementation CommentTableViewCell

-(void)awakeFromNib {
    [super awakeFromNib];
    
    [self.likesButton.layer setCornerRadius:4.f];
}

-(void)setComment:(Comment *)comment {
    _comment = comment;
    
    [self.commentTextLabel setText:comment.text];
    [self.dateLabel setText:comment.date];
    [self updateLikesButtonColor];
}

-(void)setUser:(User *)user {
    _user = user;
    [self.userInfoLabel setText:[NSString stringWithFormat:@"%@ %@", user.firstName, user.lastName]];
}

-(void)updateLikesButtonColor {
    if (self.comment) {
        [self.likesButton setTitle:self.comment.likesNumber forState:UIControlStateNormal];
        [self.likesButton setTitle:self.comment.likesNumber forState:UIControlStateSelected];
        [self.likesButton setTitle:self.comment.likesNumber forState:UIControlStateHighlighted];
        
        CGFloat alpha = self.comment.userLikes ? 0.87:0.34;
        
        [self.likesButton setBackgroundColor:[UIColor colorWithRed:0 green:122/256.f blue:1.f alpha:alpha]];
        [self.likesButton setNeedsLayout];
    }
}

-(IBAction)userDidClickLike:(id)sender {
    
    if (!self.delegate) {
        return;
    }
    
    if (self.comment.userLikes) {
        [self.delegate removeLikeFromComment:self.comment.commentID];
    } else if (self.comment.canLike) {
        [self.delegate addLikeToComment:self.comment.commentID];
    }
}

+(CGFloat)heightForText:(NSString *)text {
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
    
    return 4*offset +  MAX(17  + CGRectGetHeight(rect) + 2 + 22, 53);
}

@end
