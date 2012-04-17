//
//  ChatRoomManager.h
//  skype_bouncer
//
//  Created by Tanuma Shuhei on 12/04/17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ChatRoomManager : NSObject
{
    NSMutableDictionary *rooms;
}
+(id)sharedInstnace;
-(Boolean)hasRegistered:(NSString *)name;
-(void)addRoom:(NSString *)id roomName:(NSString *)roomName;
@end
