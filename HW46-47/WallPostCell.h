//
//  WallPostCell.h
//  (lesson45)APITest
//
//  Created by Илья Егоров on 27.06.16.
//  Copyright © 2016 Илья Егоров. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WallPost, WallPostCell, User;

@protocol WallPostCellDelegate <NSObject>

-(void)shouldPostMessage:(id)sender;

@end

@interface WallPostCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel* userInfoLabel;
@property (weak, nonatomic) IBOutlet UIImageView* avatarImageView;
@property (strong, nonatomic) User* user;
@property (strong, nonatomic) WallPost* post;
@property (strong, nonatomic) id <WallPostCellDelegate> delegate;

+ (CGFloat) heightForText:(NSString*)text;

@end
