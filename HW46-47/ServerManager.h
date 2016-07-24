//
//  ServerManager.h
//  HW46-47
//
//  Created by Илья Егоров on 30.06.16.
//  Copyright © 2016 Ilya Egorov. All rights reserved.
//

#import <Foundation/Foundation.h>

@class User, Group;

@interface ServerManager : NSObject

@property (strong, nonatomic, readonly) User* currentUser;

+ (ServerManager*) sharedManager;

-(void) authorizeUser:(void(^)(User* user)) completion;

-(void)getUser:(NSString*)userID
     onSuccess:(void(^)(User* user)) success
     onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure;

-(void)getGroup:(NSString*)groupID
     onSuccess:(void(^)(Group* group)) success
     onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure;

-(void)getFriendsWithOffset:(NSInteger)offset
                   andCount:(NSInteger)count
                  onSuccess:(void(^)(NSArray* friends)) success
                  onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure;

-(void) getGroupWall:(NSString*) groupID
          withOffset:(NSInteger) offset
            andCount:(NSInteger)count
           onSuccess:(void(^)(NSArray* friends)) success
           onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure;

-(void)postText:(NSString*)text
    onGroupWall:(NSString*) groupID
      onSuccess:(void(^)(NSArray* friends)) success
      onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure;

-(void)sendText:(NSString*)text
       toUserId:(NSString*) userID
      onSuccess:(void(^)()) success
      onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure;

-(void)sendText:(NSString*)text
     toWallPost:(NSString*) wallPostId
    onGroupWall:(NSString*) groupID
      onSuccess:(void(^)()) success
      onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure;


-(void) getMessageHistoryWithOffset:(NSInteger)offset
                           andCount:(NSInteger)count
                   andPreviewLength:(NSInteger)previewLength
                          onSuccess:(void(^)(NSArray* dialogs, long dialogsNumber)) success
                          onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure;

-(void) getMessagesWithId:(NSString*)partnerID
               WithOffset:(NSInteger)offset
                 andCount:(NSInteger)count
                onSuccess:(void(^)(NSArray* messages, long messagesNumber)) success
                onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure;

-(void) isLikedObjectOfType:(NSString*)objectType
                     withId:(NSString*)objectId
                ofCommunity:(NSString*)communityID
                  onSuccess:(void(^)(BOOL isLiked)) success
                  onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure;

-(void) addLikesToObjectOfType:(NSString*)objectType
                        withId:(NSString*)objectId
                   ofCommunity:(NSString*)communityID
                     onSuccess:(void(^)(NSDictionary* likes)) success
                     onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure;

-(void) deleteLikesFromObjectWithType:(NSString*)objectType
                               withId:(NSString*)objectId
                          ofCommunity:(NSString*)communityID
                            onSuccess:(void(^)(NSDictionary* likes)) success
                            onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure;

-(void) getCommentsForWallPost:(NSString*)wallPostID
                   ofCommunity:(NSString*)communityID
                    withOffset:(NSInteger)offset
                      andCount:(NSInteger)count
                     onSuccess:(void(^)(NSArray* comments)) success
                     onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure;

@end
