//
//  MessageManager.h
//  skype_bouncer
//
//  Created by Tanuma Shuhei on 12/04/15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MessageManager : NSObject{
    NSMutableDictionary *dict;
}

-(void)addProperty:(NSString*)key property:(NSString *)property value:(NSString *)value;
-(id)init;
+(id)sharedInstnace;

@end
