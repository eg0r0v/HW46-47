//
//  Comment.h
//  HW46-47
//
//  Created by Илья Егоров on 18.07.16.
//  Copyright © 2016 Ilya Egorov. All rights reserved.
//

#import "ServerObject.h"

@interface Comment : ServerObject

@property (strong, nonatomic) NSString* commentID;
@property (strong, nonatomic) NSString* fromUserID;
@property (strong, nonatomic) NSString* text;
@property (strong, nonatomic) NSString* date;
@property (strong, nonatomic) NSString* likesNumber;
@property (assign, nonatomic) BOOL canLike;
@property (assign, nonatomic) BOOL userLikes;


@end
