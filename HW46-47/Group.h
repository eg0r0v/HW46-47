//
//  Group.h
//  HW46-47
//
//  Created by Илья Егоров on 04.07.16.
//  Copyright © 2016 Ilya Egorov. All rights reserved.
//

#import "ServerObject.h"

@interface Group : ServerObject

@property (strong, nonatomic) NSString* groupID;
@property (strong, nonatomic) NSString* groupName;

@end
