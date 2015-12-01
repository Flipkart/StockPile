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

#pragma mark implementation of CacheProtocol

- (BOOL) cacheNode: (Node*) node
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

#pragma mark implementation of CacheAlgorithmProtocol

- (BOOL) cacheValue:(Value*) value forKey:(NSString *)key
{
    if (!key)
    {
        @throw [[CachingException alloc] initWithReason:@"Key can't be nil"];
    }
    
    Node *node = [[Node alloc] initWithKey:key value:value];
    
    BOOL cached = [self cacheNode:node];
    
    if (cached)
    {
        if (self.mirroredCache)
        {
            // call mirror
            [self.mirroredCache cacheNode:node];
        }
        
        #warning add the code to add data to the fallback and mirror cache on a separate thread
        
    }
    return cached;
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
        
        #warning you might want to get the data from the fallback or mirroed cache
    }
    
    if (node)
    {
        return node.data;
    }
    
    return nil;
}

- (void) clearCacheAndCascade
{
    [self clearCache];
    [self.mirroredCache clearCache];
    [self.fallBackCache clearCache];
}

@end
