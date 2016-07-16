//
//  WallPost.m
//  (lesson45)APITest
//
//  Created by Илья Егоров on 27.06.16.
//  Copyright © 2016 Илья Егоров. All rights reserved.
//

#import "ServerManager.h"
#import "WallPost.h"

@implementation WallPost

-(id)initWithServerResponce:(NSDictionary*)responceObject
{
    self = [super initWithServerResponce:responceObject];
    if (self) {
        self.fromUserID = [[responceObject objectForKey:@"from_id"] stringValue];
        self.text = [responceObject objectForKey:@"text"];
        self.text = [self.text stringByReplacingOccurrencesOfString:@"<br>" withString:@"\n"];
        self.likesNumber = [[[[responceObject objectForKey:@"likes"] valueForKey:@"count"] stringValue] stringByAppendingString:@" likes"];
        self.commentsNumber = [[[[responceObject objectForKey:@"comments"] valueForKey:@"count"] stringValue] stringByAppendingString:@" comments"];
        
        
        NSDate* postDate = [NSDate dateWithTimeIntervalSince1970:[[responceObject objectForKey:@"date"] longLongValue]];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"dd.MM.yyyy HH:mm"];
        self.date = [dateFormatter stringFromDate:postDate];
        
    }
    return self;
}

@end
