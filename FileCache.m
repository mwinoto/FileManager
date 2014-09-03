//
//  FileCache.m
//  RecipeBook
//
//  Created by Marc Winoto on 22/08/11.
//  Copyright 2011 Marc Winoto. All rights reserved.
//

#import "FileCache.h"

@implementation FileCache

+(FileCache *) defaultFileCache
{
    static FileCache * fileCache;
    
    @synchronized(self)
    {
        if (!fileCache)
            fileCache = [[FileCache alloc] init];
        
        return fileCache;
    }
}


- (id)init
{
    self = [super init];
    if (self) {
        _dictionary = [[NSMutableDictionary alloc] initWithCapacity:10];
    }
    
    return self;
}


-(NSData*) cachedDataForURL:(NSString*)url
{
    NSData * data = [_dictionary valueForKey:url];
    if(data!=nil)
    {
        return data;
    }
    
    NSURL * nsUrl = [[NSURL alloc] initWithString:url];
    data = [[NSData alloc] initWithContentsOfURL:nsUrl];
    [_dictionary setValue:data forKey:url];
    return data;
}

@end
