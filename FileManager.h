//
//  FileManager.h
//  RecipeBook
//
//  Created by Marc Winoto on 6/08/11.
//  Copyright 2011 Marc Winoto. All rights reserved.
//

#import <Foundation/Foundation.h>

#define CREATED 1
#define EXISTS 0
#define FAIL -1

@interface FileManager : NSObject
{
}

+(NSData *) loadData:(NSString *) file;

+(NSString *) saveData:(NSData *)data toFile:(NSString*)path;
+(NSString *) saveData:(NSData *)data toPath:(NSURL *)url;
+(NSString *) saveData:(NSData *)data toPathComponenets:(NSArray *)pathComponents withFileName:(NSString *) filename;

+(BOOL) deleteFile:(NSString*)filename;
+(BOOL) deleteFileWithRelativePath:(NSString*)filename;

+(NSString*) absolutePath:(NSString*) components;
+(NSString *) absolutePathWithComponents:(NSArray*) pathComponents returnParentDirectory:(BOOL)returnParentDirectory;

+(NSString *)nextAvailableFileInDirectory:(NSArray *) pathComponents;

+(BOOL) fileExistsAtPathComponenets:(NSArray *)pathComponents withFileName:(NSString *) filename;

+(NSInteger) initDirectory:(NSString*)directory;
+(NSString *) initDirectoryFromPathComponents:(NSArray*)pathComponents;

@end

/*
@protocol FileManagerDelegate <NSObject>

-(NSString*) directoryPath; 

@end
*/