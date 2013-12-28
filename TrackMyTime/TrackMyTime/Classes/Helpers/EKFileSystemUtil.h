//
//  EKFileSystemUtil.h
//  TrackMyTime
//
//  Created by Evgeny Karkan on 28.12.13.
//  Copyright (c) 2013 EvgenyKarkan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EKFileSystemUtil : NSObject

+ (NSData *)zippedSQLiteDatabase;
+ (void)removeZippedSQLiteDatabase;

@end
