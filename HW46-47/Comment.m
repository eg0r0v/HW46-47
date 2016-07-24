//
//  Comment.m
//  HW46-47
//
//  Created by Илья Егоров on 18.07.16.
//  Copyright © 2016 Ilya Egorov. All rights reserved.
//

#import "Comment.h"

@implementation Comment

-(instancetype)initWithServerResponce:(NSDictionary *)responceObject {
    self = [super initWithServerResponce:responceObject];
    if (self) {
        self.commentID = [[responceObject valueForKey:@"cid"] stringValue];
        self.fromUserID = [[responceObject valueForKey:@"from_id"] stringValue];
        
        self.text = [responceObject valueForKey:@"text"];
        
        NSDate* postDate = [NSDate dateWithTimeIntervalSince1970:[[responceObject objectForKey:@"date"] longLongValue]];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"HH:mm dd.MM.yyyy"];
        self.date = [dateFormatter stringFromDate:postDate];
        
        NSDictionary* likes = [responceObject objectForKey:@"likes"];
        self.likesNumber = [NSString stringWithFormat:@"%@ likes",[[likes valueForKey:@"count"] stringValue]];
        self.canLike = [[likes objectForKey:@"can_like"] boolValue];
        self.userLikes = [[likes objectForKey:@"user_likes"] boolValue];

    }
    return self;
}


@end
