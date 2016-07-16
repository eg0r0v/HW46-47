//
//  User.h
//  (lesson45)APITest
//
//  Created by Илья Егоров on 17.08.15.
//  Copyright © 2015 Илья Егоров. All rights reserved.
//

#import "ServerObject.h"

@interface User : ServerObject

@property (strong, nonatomic) NSString* userID;
@property (strong, nonatomic) NSString* firstName;
@property (strong, nonatomic) NSString* lastName;
@property (strong, nonatomic) NSURL* imageURL;

@end
