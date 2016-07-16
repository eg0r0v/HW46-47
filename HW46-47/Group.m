//
//  Group.m
//  HW46-47
//
//  Created by Илья Егоров on 04.07.16.
//  Copyright © 2016 Ilya Egorov. All rights reserved.
//

#import "Group.h"

@implementation Group

-(instancetype)initWithServerResponce:(NSDictionary *)responceObject {
    self = [super initWithServerResponce:responceObject];
    if (self) {
        self.groupID = [[responceObject objectForKey:@"gid"] stringValue];
        self.groupName = [responceObject valueForKey:@"name"];
    }
    return self;
}

@end
