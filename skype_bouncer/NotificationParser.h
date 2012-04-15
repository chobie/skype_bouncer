//
//  NotificationParser.h
//  
//
//  Created by Tanuma Shuhei on 12/04/15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NotificationParser : NSObject
{
    NSString *line;
    NSArray *array;
}

-(Boolean)isMessage;
-(Boolean)hasStatus;
-(Boolean)hasBody;
-(Boolean)hasFriendDisplayname;
-(Boolean)hasFriendlyName;
-(Boolean)hasChatName;
-(Boolean)isChat;
-(Boolean)received;
-(Boolean)sent;
-(void)setString:(NSString*)string;
+(id)initWithString:(NSString*)string;

@end
