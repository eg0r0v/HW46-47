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

@interface WallPostCell ()

@property (weak, nonatomic) IBOutlet UILabel* postTextLabel;
@property (weak, nonatomic) IBOutlet UILabel* dateLabel;
@property (weak, nonatomic) IBOutlet UILabel* likesLabel;
@property (weak, nonatomic) IBOutlet UILabel* commentsLabel;

@end

@implementation WallPostCell


-(void)setPost:(WallPost *)post {
    _post = post;
    
    [self.postTextLabel setText:post.text];
    [self.likesLabel setText:post.likesNumber];
    [self.commentsLabel setText:post.commentsNumber];
    [self.dateLabel setText:post.date];
    
}

-(void)setUser:(User*)user {
    _user = user;
    [self.userInfoLabel setText:[NSString stringWithFormat:@"%@ %@", user.firstName, user.lastName]];
}


-(void)awakeFromNib {
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
    
    return 2*offset +  MAX(17 + 3 + CGRectGetHeight(rect) + 5 + 15, 53);
}
@end
