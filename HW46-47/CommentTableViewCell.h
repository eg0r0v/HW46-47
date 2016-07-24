//
//  CommentTableViewCell.h
//  HW46-47
//
//  Created by Илья Егоров on 19.07.16.
//  Copyright © 2016 Ilya Egorov. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Comment, User;

@protocol CommentCellDelegate <NSObject>
-(void)addLikeToComment:(NSString*)commentId;
-(void)removeLikeFromComment:(NSString*)commentId;
@end

@interface CommentTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;

@property (strong, nonatomic) Comment* comment;
@property (strong, nonatomic) User* user;

@property (strong, nonatomic) id <CommentCellDelegate> delegate;

+ (CGFloat) heightForText:(NSString*)text;

@end
