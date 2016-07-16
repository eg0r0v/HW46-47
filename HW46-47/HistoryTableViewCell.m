//
//  HistoryTableViewCell.m
//  HW46-47
//
//  Created by Илья Егоров on 09.07.16.
//  Copyright © 2016 Ilya Egorov. All rights reserved.
//

#import "HistoryTableViewCell.h"
#import "HistoryObject.h"

@implementation HistoryTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setHistoryObject:(HistoryObject *)historyObject {
    
    _historyObject = historyObject;
    
    NSString* message = [[(historyObject.isOut ? @"Me: " : @"") stringByAppendingString: historyObject.body] stringByReplacingOccurrencesOfString:@"<br>" withString:@"\n"];
    if (historyObject.hasAttachments) {
        message = [message stringByAppendingString:@"ATTACHMENT"];
    }
    
    [self.messagePreviewLabel setText:message];
}
@end
