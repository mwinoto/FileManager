//
//  FileCache.h
//  RecipeBook
//
//  Created by Marc Winoto on 22/08/11.
//  Copyright 2011 Marc Winoto. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileCache : NSObject
{
    @private
    NSMutableDictionary * _dictionary;
}

+(FileCache *) defaultFileCache;
-(NSData*) cachedDataForURL:(NSString*)url;

@end
