//
//  ChatViewController.h
//  HW46-47
//
//  Created by Илья Егоров on 12.07.16.
//  Copyright © 2016 Ilya Egorov. All rights reserved.
//

#import <UIKit/UIKit.h>

@class User;

@interface ChatViewController : UITableViewController

- (instancetype)initWithUser:(User*)user;

@end
