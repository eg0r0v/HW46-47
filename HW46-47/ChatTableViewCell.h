//
//  ChatTableViewCell.h
//  HW46-47
//
//  Created by Илья Егоров on 12.07.16.
//  Copyright © 2016 Ilya Egorov. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MessageObject;

@interface ChatTableViewCell : UITableViewCell

@property (strong, nonatomic) MessageObject* messageObject;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *userShortName;

+ (CGFloat) heightForText:(NSString *)text;

@end
