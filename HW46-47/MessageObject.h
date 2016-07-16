//
//  MessageObject.h
//  HW46-47
//
//  Created by Илья Егоров on 12.07.16.
//  Copyright © 2016 Ilya Egorov. All rights reserved.
//

#import "ServerObject.h"

@interface MessageObject : ServerObject

@property (strong, nonatomic) NSString* body;
@property (strong, nonatomic) NSNumber* authorID;
@property (assign, nonatomic) BOOL isRead;
@property (strong, nonatomic) NSNumber* messageID;
@property (strong, nonatomic) NSString* date;
@property (assign, nonatomic) BOOL isOut;
@property (assign, nonatomic) BOOL hasAttachments;

@end
