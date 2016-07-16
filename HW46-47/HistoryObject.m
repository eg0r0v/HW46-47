//
//  HistoryObject.m
//  HW46-47
//
//  Created by Илья Егоров on 10.07.16.
//  Copyright © 2016 Ilya Egorov. All rights reserved.
//

#import "HistoryObject.h"

@implementation HistoryObject

-(instancetype)initWithServerResponce:(NSDictionary *)responceObject {
    self = [super initWithServerResponce:responceObject];
    if (self) {
        self.body = [responceObject objectForKey:@"body"];
        self.authorID = [responceObject objectForKey:@"uid"];
        self.isRead = [[responceObject objectForKey:@"out"] boolValue];
        self.messageID = [responceObject objectForKey:@"mid"];
        
        NSDate* postDate = [NSDate dateWithTimeIntervalSince1970:[[responceObject objectForKey:@"date"] longLongValue]];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"HH:mm dd.MM.yyyy"];
        self.date = [dateFormatter stringFromDate:postDate];

        self.isOut = [[responceObject objectForKey:@"out"] boolValue];
        self.title = [responceObject objectForKey:@"title"];
        
        self.hasAttachments = [responceObject objectForKey:@"attachment"];
    }
    return self;
}


@end
