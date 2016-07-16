//
//  HistoryObject.h
//  HW46-47
//
//  Created by Илья Егоров on 10.07.16.
//  Copyright © 2016 Ilya Egorov. All rights reserved.
//

#import "ServerObject.h"

@interface HistoryObject : ServerObject

@property (strong, nonatomic) NSString* body;
@property (strong, nonatomic) NSString* authorID;
@property (assign, nonatomic) BOOL isRead;
@property (strong, nonatomic) NSNumber* messageID;
@property (strong, nonatomic) NSString* date;
@property (assign, nonatomic) BOOL isOut;
@property (strong, nonatomic) NSString* title;
@property (assign, nonatomic) BOOL hasAttachments;

@end
