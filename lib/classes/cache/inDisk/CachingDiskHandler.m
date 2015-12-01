//
//  CachingDiskHandler.m
//  Pods
//
//  Created by Prabodh Prakash on 04/09/15.
//
//

#import "CachingDiskHandler.h"
#import "CachingException.h"
#import "NSFileManager+AttributesExtension.h"

@implementation CachingDiskHandler

@synthesize filePath = _filePath;

- (BOOL) cacheNode: (Node*) node
{
    BOOL isCached = YES;
    
    NSString *filePath = [self.filePath stringByAppendingPathComponent:node.key];
    
    NSData* fileData = [NSKeyedArchiver archivedDataWithRootObject:node.data];

    NSFileManager * fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath:filePath])
    {
        [fileManager createFileAtPath:filePath contents:fileData attributes:nil];
        
        NSError* error;
        NSData* ttlDate = [NSKeyedArchiver archivedDataWithRootObject:node.data.ttlDate];
        
        [fileManager setData:ttlDate forExtendedAttribute:@"ttlDate" ofItemAtPath:filePath error:&error];
    }
    else
    {
        NSError* error = nil;
        
        [fileManager removeItemAtPath:filePath error:&error];
        
        if (!error)
        {
            [fileManager createFileAtPath:filePath contents:fileData attributes:nil];
        }
        else
        {
            isCached = NO;
        }
    }
    
    return isCached;
}

- (Node*) getNodeForKey:(NSString*) key
{
    NSString *filePath = [self.filePath stringByAppendingPathComponent:key];

    NSFileManager * fileManager = [NSFileManager defaultManager];
    
    NSError* error;
    NSData* ttlDateArchivedData = [fileManager dataForExtendedAttribute:@"ttlDate" ofItemAtPath:filePath error:&error];
    
    NSDate* ttlDate = (NSDate*)[NSKeyedUnarchiver unarchiveObjectWithData:ttlDateArchivedData];
    
    Value* value = nil;
    if ([ttlDate compare:[NSDate date]] != NSOrderedDescending)
    {
        NSData* fileData = [fileManager contentsAtPath:filePath];
        value = (Value*)[NSKeyedUnarchiver unarchiveObjectWithData:fileData];
    }
    
    Node* node = [[Node alloc] initWithKey:key value:value];
    return node;
}

- (void) clearCache
{
    #warning complete the code
}

- (unsigned long long int)folderSize:(NSString *)folderPath {
    NSArray *filesArray = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:folderPath error:nil];
    NSEnumerator *filesEnumerator = [filesArray objectEnumerator];
    NSString *fileName;
    unsigned long long int fileSize = 0;
    
    while (fileName = [filesEnumerator nextObject]) {
        NSDictionary *fileDictionary = [[NSFileManager defaultManager] attributesOfItemAtPath:[folderPath stringByAppendingPathComponent:fileName] error:nil];
        fileSize += [fileDictionary fileSize];
    }
    
    return fileSize;
}
@end
