//
//  WallPostViewController.h
//  HW46-47
//
//  Created by Илья Егоров on 17.07.16.
//  Copyright © 2016 Ilya Egorov. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WallPost;

@interface WallPostViewController : UITableViewController

@property (strong, nonatomic) WallPost* wallPost;
@end
