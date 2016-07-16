//
//  HistoryTableViewCell.h
//  HW46-47
//
//  Created by Илья Егоров on 09.07.16.
//  Copyright © 2016 Ilya Egorov. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HistoryObject;

@interface HistoryTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView* avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel* userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel* messagePreviewLabel;

@property (strong, nonatomic) HistoryObject* historyObject;

@end
