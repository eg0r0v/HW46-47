//
//  WallPost.h
//  (lesson45)APITest
//
//  Created by Илья Егоров on 27.06.16.
//  Copyright © 2016 Илья Егоров. All rights reserved.
//

#import "ServerObject.h"

@interface WallPost : ServerObject

@property (strong, nonatomic) NSString* fromUserID;
@property (strong, nonatomic) NSString* text;
@property (strong, nonatomic) NSString* likesNumber;
@property (strong, nonatomic) NSString* commentsNumber;
@property (strong, nonatomic) NSString* date;
@property (strong, nonatomic) NSString* wallPostID;

@end
