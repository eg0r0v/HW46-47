//
//  ServerManager.m
//  HW46-47
//
//  Created by Илья Егоров on 30.06.16.
//  Copyright © 2016 Ilya Egorov. All rights reserved.
//

#import "ServerManager.h"
#import "AFNetworking.h"
#import "User.h"
#import "Group.h"
#import "LoginViewController.h"
#import "AccessToken.h"
#import "WallPost.h"
#import "HistoryObject.h"
#import "MessageObject.h"
#import "Comment.h"

@interface ServerManager()

@property (strong, nonatomic) AFHTTPRequestOperationManager* requestOperationManager;
@property (strong, nonatomic) AccessToken* accessToken;

@end


@implementation ServerManager
+ (ServerManager*) sharedManager {
    
    static ServerManager* manager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[ServerManager alloc] init];
    });
    
    return manager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        NSURL* url = [NSURL URLWithString:@"https://api.vk.com/method/"];
        self.requestOperationManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:url];
    }
    return self;
}

-(void) authorizeUser:(void (^)(User *))completion {
    LoginViewController* vc = [[LoginViewController alloc] initWithCompletionBlock:^(AccessToken *token) {
        self.accessToken = token;
        
        if (token) {
            [self getUser:token.userID onSuccess:^(User *user) {
                
                if (completion) {
                    completion(user);
                }
                
            } onFailure:^(NSError *error, NSInteger statusCode) {
                if (completion) {
                    completion(nil);
                }
            }];
        } else if (completion) {
            completion(nil);
        }
    }];
    
    
    UINavigationController* nvc = [[UINavigationController alloc] initWithRootViewController:vc];
    
    UIViewController* mainVC = [[[[UIApplication sharedApplication] windows] firstObject] rootViewController];
    
    [mainVC presentViewController:nvc animated:YES completion:nil];
    
}


-(void)getUser:(NSString*)userID
     onSuccess:(void(^)(User* user)) success
     onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure {
    
    NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:
                            userID,         @"user_ids",
                            @"photo_50",    @"fields",
                            @"nom",         @"name_case",   nil];
    
    [self.requestOperationManager
     GET:@"users.get"
     parameters:params
     success:^void(AFHTTPRequestOperation * __nonnull operation, id __nonnull responseObject) {
         // NSLog(@"JSON: %@", responseObject);
         
         NSArray* dictsArray = [responseObject objectForKey:@"response"];
         
         if ([dictsArray count] > 0) {
             User* user = [[User alloc] initWithServerResponce:[dictsArray firstObject]];
             
             if (success) {
                 success(user);
             }
         } else if (failure) {
             failure(nil, operation.response.statusCode);
         }
         
     } failure:^void(AFHTTPRequestOperation * __nonnull operation, NSError * __nonnull error) {
         NSLog(@"error: %@", error);
         
         if (failure) {
             failure(error, operation.response.statusCode);
         }
         
     }];
    
    
}

-(void)getGroup:(NSString*)groupID
      onSuccess:(void(^)(Group* group)) success
      onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure {
    
    NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:
                            groupID,         @"group_id",  nil];
    
    [self.requestOperationManager
     GET:@"groups.getById"
     parameters:params
     success:^void(AFHTTPRequestOperation * __nonnull operation, id __nonnull responseObject) {
         // NSLog(@"JSON: %@", responseObject);
         
         NSArray* dictsArray = [responseObject objectForKey:@"response"];
         
         if ([dictsArray count] > 0) {
             Group* group = [[Group alloc] initWithServerResponce:[dictsArray firstObject]];
             
             if (success) {
                 success(group);
             }
         } else if (failure) {
             failure(nil, operation.response.statusCode);
         }
         
     } failure:^void(AFHTTPRequestOperation * __nonnull operation, NSError * __nonnull error) {
         NSLog(@"error: %@", error);
         
         if (failure) {
             failure(error, operation.response.statusCode);
         }
         
     }];

    
}


-(void)getFriendsWithOffset:(NSInteger)offset
                   andCount:(NSInteger)count
                  onSuccess:(void(^)(NSArray* friends)) success
                  onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure {
    
    
    NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:
                            @"3294219",     @"user_id",
                            @"name",        @"order",
                            @(count),       @"count",
                            @(offset),      @"offset",
                            @"photo_50",    @"fields",
                            @"nom",         @"name_case",   nil];
    
    [self.requestOperationManager
     GET:@"friends.get"
     parameters:params
     success:^void(AFHTTPRequestOperation * __nonnull operation, id __nonnull responseObject) {
         // NSLog(@"JSON: %@", responseObject);
         
         NSArray* dictsArray = [responseObject objectForKey:@"response"];
         
         NSMutableArray* objectsArray = [NSMutableArray array];
         
         
         for (NSDictionary* dict in dictsArray) {
             
             User* user = [[User alloc] initWithServerResponce:dict];
             [objectsArray addObject:user];
         }
         
         if (success) {
             success(objectsArray);
         }
         
     } failure:^void(AFHTTPRequestOperation * __nonnull operation, NSError * __nonnull error) {
         NSLog(@"error: %@", error);
         
         if (failure) {
             failure(error, operation.response.statusCode);
         }
         
     }];
}

-(void)getGroupWall:(NSString*)groupID
         withOffset:(NSInteger)offset
           andCount:(NSInteger)count
          onSuccess:(void (^)(NSArray *))success
          onFailure:(void (^)(NSError *, NSInteger))failure {
    
    if (![groupID hasPrefix:@"-"]) {
        groupID = [@"-" stringByAppendingString:groupID];
    }
    
    offset += 1; // pinned post
    
    NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:
                            groupID,    @"owner_id",
                            @(count),   @"count",
                            @(offset),  @"offset",
                            @"all",     @"filter",   nil];
    
    [self.requestOperationManager
     GET:@"wall.get"
     parameters:params
     success:^void(AFHTTPRequestOperation * __nonnull operation, id __nonnull responseObject) {
         // NSLog(@"JSON: %@", responseObject);
         
         NSArray* dictsArray = [responseObject objectForKey:@"response"];
         
         if ([dictsArray count] > 1) {
             dictsArray = [dictsArray subarrayWithRange:NSMakeRange(1, (int)[dictsArray count] - 1)];
         } else {
             dictsArray = nil;
         }
         
         NSMutableArray* objectsArray = [NSMutableArray array];
         
         for (NSDictionary* dict in dictsArray) {
             WallPost* post = [[WallPost alloc] initWithServerResponce:dict];
             [objectsArray addObject:post];
         }
         
         if (success) {
             success(objectsArray);
         }
         
     } failure:^void(AFHTTPRequestOperation * __nonnull operation, NSError * __nonnull error) {
         NSLog(@"error: %@", error);
         
         if (failure) {
             failure(error, operation.response.statusCode);
         }
         
     }];
}

-(void)postText:(NSString*)text
    onGroupWall:(NSString*) groupID
      onSuccess:(void(^)(NSArray* friends)) success
      onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure {
    
    if (![groupID hasPrefix:@"-"]) {
        groupID = [@"-" stringByAppendingString:groupID];
    }
    
    NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:
                            groupID,            @"owner_id",
                            text,               @"message",
                            self.accessToken.token, @"access_token",nil];
    
    [self.requestOperationManager
     POST:@"wall.post"
     parameters:params
     success:^void(AFHTTPRequestOperation * __nonnull operation, id __nonnull responseObject) {
         // NSLog(@"JSON: %@", responseObject);
         
         if (success) {
             success(responseObject);
         }
         
     } failure:^void(AFHTTPRequestOperation * __nonnull operation, NSError * __nonnull error) {
         NSLog(@"error: %@", error);
         
         if (failure) {
             failure(error, operation.response.statusCode);
         }
     }];
    
    
}


-(void)sendText:(NSString*)text
       toUserId:(NSString*) userID
      onSuccess:(void(^)()) success
      onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure {
    
    NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:
                            userID,             @"user_id",
                            text,               @"message",
                            self.accessToken.token, @"access_token",nil];
    
    [self.requestOperationManager
     POST:@"messages.send"
     parameters:params
     success:^void(AFHTTPRequestOperation * __nonnull operation, id __nonnull responseObject) {
         if (success) {
             success(responseObject);
         }
         
     } failure:^void(AFHTTPRequestOperation * __nonnull operation, NSError * __nonnull error) {
         NSLog(@"error: %@", error);
         
         if (failure) {
             failure(error, operation.response.statusCode);
         }
     }];
    
}

-(void)sendText:(NSString*)text
       toWallPost:(NSString*) wallPostId
    onGroupWall:(NSString*) groupID
      onSuccess:(void(^)()) success
      onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure {
    
    if (![groupID hasPrefix:@"-"]) {
        groupID = [@"-" stringByAppendingString:groupID];
    }

    NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:
                            groupID,            @"owner_id",
                            wallPostId,             @"post_id",
                            text,               @"message",
                            self.accessToken.token, @"access_token",nil];
    
    [self.requestOperationManager
     POST:@"wall.createComment"
     parameters:params
     success:^void(AFHTTPRequestOperation * __nonnull operation, id __nonnull responseObject) {
         if (success) {
             success(responseObject);
         }
         
     } failure:^void(AFHTTPRequestOperation * __nonnull operation, NSError * __nonnull error) {
         NSLog(@"error: %@", error);
         
         if (failure) {
             failure(error, operation.response.statusCode);
         }
     }];
    
}


-(void) getMessageHistoryWithOffset:(NSInteger)offset
                           andCount:(NSInteger)count
                   andPreviewLength:(NSInteger)previewLength
                          onSuccess:(void(^)(NSArray* dialogs, long dialogsNumber)) success
                          onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure {
    
    
//    offset += 1; // pinned post
    
    NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:
                            @(previewLength),  @"preview_length",
                            @(count),   @"count",
                            @(offset),  @"offset",
                            self.accessToken.token, @"access_token", nil];
    
    [self.requestOperationManager
     GET:@"messages.getDialogs"
     parameters:params
     success:^void(AFHTTPRequestOperation * __nonnull operation, id __nonnull responseObject) {
         // NSLog(@"JSON: %@", responseObject);
         
         NSArray* dictsArray = [responseObject objectForKey:@"response"];
         
         long dialogsCount = 0;
         if ([dictsArray count] > 1) {
             dialogsCount = [[dictsArray firstObject] longValue];
             dictsArray = [dictsArray subarrayWithRange:NSMakeRange(1, (int)[dictsArray count] - 1)];
         } else {
             dictsArray = nil;
         }
         
         NSMutableArray* objectsArray = [NSMutableArray array];
         
         
         for (NSDictionary* dict in dictsArray) {
             HistoryObject* post = [[HistoryObject alloc] initWithServerResponce:dict];
             [objectsArray addObject:post];
         }
         
         if (success) {
             success(objectsArray, dialogsCount);
         }
         
     } failure:^void(AFHTTPRequestOperation * __nonnull operation, NSError * __nonnull error) {
         NSLog(@"error: %@", error);
         
         if (failure) {
             failure(error, operation.response.statusCode);
         }
         
     }];
}

-(void) getMessagesWithId:(NSString*)partnerID
               WithOffset:(NSInteger)offset
                 andCount:(NSInteger)count
                onSuccess:(void(^)(NSArray* messages, long messagesNumber)) success
                onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure {
    
    
    
    NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:
                            partnerID,  @"user_id",
                            @(count),   @"count",
                            @(offset),  @"offset",
                            @"0", @"rev",
                            self.accessToken.token, @"access_token", nil];
    
    [self.requestOperationManager
     GET:@"messages.getHistory"
     parameters:params
     success:^void(AFHTTPRequestOperation * __nonnull operation, id __nonnull responseObject) {
         // NSLog(@"JSON: %@", responseObject);
         
         NSArray* dictsArray = [responseObject objectForKey:@"response"];
         
         long messagesCount = 0;
         if ([dictsArray count] > 1) {
             messagesCount = [[dictsArray firstObject] longValue];
             dictsArray = [dictsArray subarrayWithRange:NSMakeRange(1, (int)[dictsArray count] - 1)];
         } else {
             dictsArray = nil;
         }
         
         NSMutableArray* objectsArray = [NSMutableArray array];
         
         for (NSDictionary* dict in dictsArray) {
             MessageObject * message = [[MessageObject alloc] initWithServerResponce:dict];
             [objectsArray addObject:message];
         }
         
         if (success) {
             success(objectsArray, messagesCount);
         }
         
     } failure:^void(AFHTTPRequestOperation * __nonnull operation, NSError * __nonnull error) {
         NSLog(@"error: %@", error);
         if (failure) {
             failure(error, operation.response.statusCode);
         }
     }];
}

-(void) isLikedObjectOfType:(NSString*)objectType
                        withId:(NSString*)objectId
                   ofCommunity:(NSString*)communityID
                  onSuccess:(void(^)(BOOL isLiked)) success
                     onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure {
    
    if (![communityID hasPrefix:@"-"]) {
        communityID = [@"-" stringByAppendingString:communityID];
    }
    
    NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:
                            objectId,  @"item_id",
                            communityID, @"owner_id",
                            objectType,    @"type",
                            self.accessToken.token, @"access_token", nil];
    
    [self.requestOperationManager
     GET:@"likes.isLiked"
     parameters:params
     success:^void(AFHTTPRequestOperation * __nonnull operation, id __nonnull responseObject) {
         // NSLog(@"JSON: %@", responseObject);
         
         BOOL result = [[responseObject objectForKey:@"response"] boolValue];
         
         if (success) {
             success(result);
         }
         
     } failure:^void(AFHTTPRequestOperation * __nonnull operation, NSError * __nonnull error) {
         NSLog(@"error: %@", error);
         if (failure) {
             failure(error, operation.response.statusCode);
         }
     }];
}



-(void) addLikesToObjectOfType:(NSString*)objectType
                        withId:(NSString*)objectId
                   ofCommunity:(NSString*)communityID
                     onSuccess:(void(^)(NSDictionary* likes)) success
                     onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure {
    
    if (![communityID hasPrefix:@"-"]) {
        communityID = [@"-" stringByAppendingString:communityID];
    }
    
    NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:
                            objectId,  @"item_id",
                            communityID, @"owner_id",
                            objectType,    @"type",
                            self.accessToken.token, @"access_token", nil];
    
    [self.requestOperationManager
     GET:@"likes.add"
     parameters:params
     success:^void(AFHTTPRequestOperation * __nonnull operation, id __nonnull responseObject) {
         // NSLog(@"JSON: %@", responseObject);
         
         NSDictionary* dictsArray = [responseObject objectForKey:@"response"];
         
         if (success) {
             success(dictsArray);
         }
         
     } failure:^void(AFHTTPRequestOperation * __nonnull operation, NSError * __nonnull error) {
         NSLog(@"error: %@", error);
         if (failure) {
             failure(error, operation.response.statusCode);
         }
     }];
}

-(void) deleteLikesFromObjectWithType:(NSString*)objectType
                        withId:(NSString*)objectId
                   ofCommunity:(NSString*)communityID
                     onSuccess:(void(^)(NSDictionary* likes)) success
                     onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure {
    
    if (![communityID hasPrefix:@"-"]) {
        communityID = [@"-" stringByAppendingString:communityID];
    }
    
    NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:
                            objectId,  @"item_id",
                            communityID, @"owner_id",
                            objectType,    @"type",
                            self.accessToken.token, @"access_token", nil];
    
    [self.requestOperationManager
     GET:@"likes.delete"
     parameters:params
     success:^void(AFHTTPRequestOperation * __nonnull operation, id __nonnull responseObject) {
         // NSLog(@"JSON: %@", responseObject);
         
         NSDictionary* dictsArray = [responseObject objectForKey:@"response"];
         
         if (success) {
             success(dictsArray);
         }
         
     } failure:^void(AFHTTPRequestOperation * __nonnull operation, NSError * __nonnull error) {
         NSLog(@"error: %@", error);
         if (failure) {
             failure(error, operation.response.statusCode);
         }
     }];
}



-(void) getCommentsForWallPost:(NSString*)wallPostID
                   ofCommunity:(NSString*)communityID
                    withOffset:(NSInteger)offset
                      andCount:(NSInteger)count
                     onSuccess:(void(^)(NSArray* comments)) success
                     onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure {
    
    if (![communityID hasPrefix:@"-"]) {
        communityID = [@"-" stringByAppendingString:communityID];
    }
    
    NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:
                            wallPostID,  @"post_id",
                            communityID, @"owner_id",
                            @(count),   @"count",
                            @(offset),  @"offset",
                            @"1", @"need_likes",
                            self.accessToken.token, @"access_token", nil];
    
    [self.requestOperationManager
     GET:@"wall.getComments"
     parameters:params
     success:^void(AFHTTPRequestOperation * __nonnull operation, id __nonnull responseObject) {
         // NSLog(@"JSON: %@", responseObject);
         
         NSArray* dictsArray = [responseObject objectForKey:@"response"];
         
         long messagesCount = 0;
         if ([dictsArray count] > 1) {
             messagesCount = [[dictsArray firstObject] longValue];
             dictsArray = [dictsArray subarrayWithRange:NSMakeRange(1, (int)[dictsArray count] - 1)];
         } else {
             dictsArray = nil;
         }
         
         NSMutableArray* objectsArray = [NSMutableArray array];
         
         for (NSDictionary* dict in dictsArray) {
             Comment * comment = [[Comment alloc] initWithServerResponce:dict];
             [objectsArray addObject:comment];
         }
         
         if (success) {
             success(objectsArray);
         }
         
     } failure:^void(AFHTTPRequestOperation * __nonnull operation, NSError * __nonnull error) {
         NSLog(@"error: %@", error);
         if (failure) {
             failure(error, operation.response.statusCode);
         }
     }];
    
}

@end
