//
//  WriteMessageViewController.h
//  HW46-47
//
//  Created by Илья Егоров on 04.07.16.
//  Copyright © 2016 Ilya Egorov. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Group, User;

@interface WriteMessageViewController : UIViewController

@property (strong, nonatomic) id objectToSend;

- (instancetype)initWithGroup:(Group*)groupToSend;
- (instancetype)initWithUser:(User*)userToSend;

@end
