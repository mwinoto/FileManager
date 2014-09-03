//
//  FileManager.m
//  RecipeBook
//
//  Created by Marc Winoto on 6/08/11.
//  Copyright 2011 Marc Winoto. All rights reserved.
//

#import "FileManager.h"

@interface FileManager ()

+(NSString *) documentDirectory;
+(NSArray *) searchForFilesWithComponents:(NSArray*) pathComponents;
// TODO: Need more convienence methods for extracting components from paths


@end

@implementation FileManager

#pragma mark - 
#pragma mark Private Methods

// FIXME: Does this return a / at the end?
+(NSString*) documentDirectory
{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];    
}

+(NSArray *) searchForFilesWithComponents:(NSArray*) pathComponents
{
    NSMutableArray * arr = [[NSMutableArray alloc] init];
    
    NSString * directoryPath = [FileManager absolutePathWithComponents:pathComponents returnParentDirectory:YES];
    NSString * filename = [pathComponents lastObject];
    
    NSError * error = nil;
    NSFileManager * fileManager = [NSFileManager defaultManager];
    NSArray * contents = [fileManager contentsOfDirectoryAtPath:directoryPath error:&error];
    if(error)
    {
#if DEBUG
        NSLog(@"%@", [error description]);
#endif
    }
    else
    {
        //There are results so look for the ones that we want and put those into an array
        //NSString * regexString = [NSString stringWithFormat:@"^%@", filename];
        //NSRegularExpression * regex = [NSRegularExpression regularExpressionWithPattern:regexString 
        //                                                                        options:NSRegularExpressionCaseInsensitive 
        //                                                                          error:&error];
        for(NSString * c in contents)
        {
            // Short circuits
            if([filename length] > [c length])
            {
                continue;
            }
            
            NSString * substring = [c substringToIndex:[filename length]];
            if([filename isEqualToString:substring]) // substrings match! They are equal!
            {
                [arr addObject:c]; // Keep track of all the file names.
            }
        }
    }
    
    return arr;    
}

// Check that the directory is there and create it if it is not.
+(NSInteger) initDirectory:(NSString*)directory
{
    NSFileManager * fileManager = [NSFileManager defaultManager];
    NSString * absPath = [[FileManager documentDirectory] stringByAppendingPathComponent:directory];
    BOOL isDirectory;
    if([fileManager fileExistsAtPath:absPath isDirectory:&isDirectory] && isDirectory)
        return EXISTS;
    else
    {
        NSError * error = nil;
        // Do something with the error
        // Have to figure out what this does.
        if ([fileManager createDirectoryAtPath:absPath withIntermediateDirectories:YES attributes:nil error:&error]) 
        {
            return CREATED;
        }
        else
        {
#if DEBUG
            NSLog(@"%@", [error description]);
#endif
            return FAIL;
        }
    }
}

// FIXME: There must be a better way to do this
+(NSString *) initDirectoryFromPathComponents:(NSArray*)pathComponents
{
    // Append the index to the end of the string
    NSString * path = [pathComponents componentsJoinedByString:@"/"];
    
    NSInteger result = [FileManager initDirectory:path];
    if(result==FAIL)
    {
        [NSException raise:@"Directory creation" format:@"initDirectory returned with %d", result];
    }
    return path;
}


#pragma mark -
#pragma mark Public File Methods


+(NSString*) absolutePath:(NSString*) component
{
    NSString * documentDir = [FileManager documentDirectory];
    NSString * absolutePath = [documentDir stringByAppendingPathComponent:component];
    return absolutePath;    
}

// Take a relative path to a file and return the absolute path to a file
+(NSString*) absolutePathWithComponents:(NSArray*) pathComponents  returnParentDirectory:(BOOL)returnParentDirectory
{
    NSString * documentDir = [FileManager documentDirectory];

    NSString * pathString;
    
    if(returnParentDirectory)
    {
        // Assume that n-1 components is the base directory
        NSRange directoryRange = NSMakeRange(0, [pathComponents count]-1);
        NSArray * directoryPathComponents = [pathComponents subarrayWithRange:directoryRange];
        pathString = [directoryPathComponents componentsJoinedByString:@"/"];    
    }
    else
    {
        pathString = [pathComponents componentsJoinedByString:@"/"];        
    }

    NSString * absolutePath = [documentDir stringByAppendingPathComponent:pathString];
    return absolutePath;
}

// Search for files with the same prefix and return the last path component that 
// can be used to update your path
+(NSString *)nextAvailableFileInDirectory:(NSArray *) pathComponents
{
    NSArray * similarFiles = [FileManager searchForFilesWithComponents:pathComponents];
    NSInteger suffix = [similarFiles count];
    
    // Append the index to the end of the string
    NSString * last = [pathComponents lastObject];
    last = [last stringByAppendingFormat:@"_%d", suffix];
    return last;
}


#pragma mark -
#pragma mark File Methods

+(BOOL) fileExistsAtPathComponenets:(NSArray *)pathComponents withFileName:(NSString *) filename
{
    NSString * path = [pathComponents componentsJoinedByString:@"/"];
    NSString * file = [FileManager absolutePath:path];
    NSFileManager * fileManager = [NSFileManager defaultManager];
    return [fileManager fileExistsAtPath:file];
}

+(void) appendLine:(NSString*)line toFile:(NSString*) file
{
    NSFileHandle *aFileHandle = [NSFileHandle fileHandleForWritingAtPath:file]; //telling aFilehandle what file write to
    [aFileHandle truncateFileAtOffset:[aFileHandle seekToEndOfFile]]; //setting aFileHandle to write at the end of the file
    [aFileHandle writeData:[line dataUsingEncoding:NSUTF8StringEncoding]]; //    
}

+(NSString *) saveData:(NSData *)data toFile:(NSString*)path
{
    NSString * file = [FileManager absolutePath:path];
    NSFileManager * fileManager = [NSFileManager defaultManager];
    
    if(![fileManager fileExistsAtPath:file])
    {
        if(![fileManager createFileAtPath:file contents:data attributes:nil])
        {
#if DEBUG
            NSLog(@"Save to path components failed!");
#endif
        }
        return file;
    }
    return nil;    
}


// Needs to take the path components up to the last root
// Then save relative to the base directory
//
+(NSString *) saveData:(NSData *)data toPath:(NSURL *)url
{
    NSArray * pathComponents = [url pathComponents];
    NSRange range = NSMakeRange(0, [pathComponents count]-1);// The containing directory
    NSArray * directoryPath = [pathComponents subarrayWithRange:range];
    
    // Create the directory and create the filename. Ready to save things!
    // Returns an unused directory name
    NSString * filename = [pathComponents lastObject];
    NSString * directory = [FileManager initDirectoryFromPathComponents:directoryPath];
    NSString * filePath = [directory stringByAppendingPathComponent:filename];
    
    NSFileManager * fileManager = [NSFileManager defaultManager];

    // Write the file out if it does not exist
    // What about files from different 

    if(![fileManager fileExistsAtPath:filePath])
    {
        if(![data writeToFile:filePath atomically:YES])
        {
#if DEBUG
            NSLog(@"Save to URL failed!");
#endif
        }
        return filePath;
    }
    return nil;
}

+(NSString *) saveData:(NSData *)data toPathComponenets:(NSArray *)pathComponents withFileName:(NSString *) filename
{
    NSString * directory = [FileManager initDirectoryFromPathComponents:pathComponents];
    NSString * file = [directory stringByAppendingPathComponent:filename];
    file = [FileManager absolutePath:file];
    
    NSFileManager * fileManager = [NSFileManager defaultManager];
    
    // Write the file out if it does not exist
    // What about files from different 
    
    if(![fileManager fileExistsAtPath:file])
    {
        if(![data writeToFile:file atomically:YES])
        {
#if DEBUG
            NSLog(@"Save to path components failed!");
#endif
        }
        return file;
    }
    return nil;    
}

+(BOOL) deleteFile:(NSString*)filename
{
    NSFileManager * fileManager = [NSFileManager defaultManager];
    NSError * error;
    if([fileManager removeItemAtPath:filename error:&error])
        return YES;
    else
    {
#if DEBUG
        NSLog(@"Deletion error %@", [error description]);
#endif
        return NO;
    }
}

+(BOOL) deleteFileWithRelativePath:(NSString*)filename
{
    NSFileManager * fileManager = [NSFileManager defaultManager];
    NSError * error;
    if([fileManager removeItemAtPath:[FileManager absolutePath:filename] error:&error])
        return YES;
    else
    {
#if DEBUG
        NSLog(@"Deletion error %@", [error description]);
#endif
        return NO;
    }
}

#pragma mark -
#pragma mark Loading methods

+(NSData *) loadData:(NSString *) file
{
    NSString * absolutePath = [self absolutePath:file];
    NSFileManager * fileManager = [NSFileManager defaultManager];
    return [fileManager contentsAtPath:absolutePath];
}

@end
