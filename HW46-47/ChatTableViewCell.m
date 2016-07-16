//
//  ChatTableViewCell.m
//  HW46-47
//
//  Created by Илья Егоров on 12.07.16.
//  Copyright © 2016 Ilya Egorov. All rights reserved.
//

#import "ChatTableViewCell.h"
#import "MessageObject.h"

@interface ChatTableViewCell ()

@property (weak, nonatomic) IBOutlet UITextView *messageTextView;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;


@end
@implementation ChatTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setMessageObject:(MessageObject *)messageObject {
    _messageObject = messageObject;
    
    [self.messageTextView setText:messageObject.body];
    [self.dateLabel setText:messageObject.date];
}


+ (CGFloat) heightForText:(NSString *)text {
    
    CGFloat rightOffset = 9.f;
    
    CGFloat imageLeftOffset = 8+50+2;
    
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
    
    CGRect rect = [text boundingRectWithSize:CGSizeMake([UIApplication sharedApplication].keyWindow.frame.size.width - rightOffset - imageLeftOffset, CGFLOAT_MAX)
                                     options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                  attributes:attributes
                                     context:nil];
    
    return MAX(27 + CGRectGetHeight(rect) + 8, 63);
}


@end
