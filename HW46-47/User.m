//
//  User.m
//  (lesson45)APITest
//
//  Created by Илья Егоров on 17.08.15.
//  Copyright © 2015 Илья Егоров. All rights reserved.
//

#import "User.h"

@implementation User

-(id)initWithServerResponce:(NSDictionary*)responceObject;
{
    self = [super initWithServerResponce:responceObject];
    if (self) {
        self.userID = [[responceObject objectForKey:@"uid"] stringValue];
        
        self.firstName = [responceObject objectForKey:@"first_name"];
        self.lastName = [responceObject objectForKey:@"last_name"];
        
        NSString* urlString = [responceObject objectForKey:@"photo_50"];
        
        if (urlString) {
            self.imageURL = [NSURL URLWithString:urlString];
        }
    }
    return self;
}
@end
