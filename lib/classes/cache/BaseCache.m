//
//  BaseCache.m
//  Pods
//
//  Created by Prabodh Prakash on 06/09/15.
//
//

#import "BaseCache.h"
#import "CachingException.h"

@implementation BaseCache

//@synthesize path;

#pragma mark implementation of CacheAlgorithmProtocol

- (NSArray*) cacheNode: (Node*) node error:(NSError **)outError
{
    @throw [[CachingException alloc] initWithReason:@"Must be called to a sub class of BaseCache"];
}

- (Node*) getNodeForKey:(id<NSCopying, NSMutableCopying, NSSecureCoding>) key
{
    @throw [[CachingException alloc] initWithReason:@"Must be called to a sub class of BaseCache"];
}

- (void) clearCache
{
    @throw [[CachingException alloc] initWithReason:@"Must be called to a sub class of BaseCache"];
}

#pragma mark implementation of CacheProtocol

- (void) cacheAsyncValue:(Value*) value forKey:(NSString *)key{
    if (!key)
    {
        @throw [[CachingException alloc] initWithReason:@"Key can't be nil"];
    }
    __block Value* valueInternal = value;
    __block NSString* keyInternal = key;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [self cacheValue:valueInternal forKey:keyInternal];
    });
}

- (BOOL) cacheValue:(Value*) value forKey:(NSString *)key
{
    if (!key)
    {
        @throw [[CachingException alloc] initWithReason:@"Key can't be nil"];
    }
    
    Node *node = [[Node alloc] initWithKey:key value:value];

    NSError *error = nil;
    __block NSArray *nodesRemoved = [self cacheNode:node error:&error];
    
    // mirror the data
    if (!error && self.mirroredCache)
    {
        [self.mirroredCache cacheAsyncValue:value forKey:key];
    }
    
    // handle the data which overflowed from the current cache
    if (nodesRemoved && self.overFlowCache)
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            for (Node* node in nodesRemoved) {
                NSError *error;
                [self.overFlowCache cacheNode:node error:&error];
            }
        });
    }
    return !error;
}

- (Value*) getValueForKey:(NSString*) key
{
    Node *node = [self getNodeForKey:key];
    
    if (!node.data)
    {
        if (self.mirroredCache)
        {
            node = [self.mirroredCache getNodeForKey:key];
        }
        else if (self.overFlowCache)
        {
            node = [self.overFlowCache getNodeForKey:key];
        }
        
        if (node.data)
        {
            NSError *error = nil;
            [self cacheNode:node error:&error];
        }
    }
    
    return node.data;
}

- (void) nodeDeleted:(Node *)node
{
    @throw [[CachingException alloc] initWithReason:@"Must be implemented by the sub class of BaseCache"];
}

- (void) clearCacheAndCascade
{
    [self clearCache];
    [self.mirroredCache clearCache];
    [self.overFlowCache clearCache];
}

@end
