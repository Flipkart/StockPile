//
//  BaseCache.h
//  Pods
//
//  Created by Prabodh Prakash on 06/09/15.
//
//

#import <Foundation/Foundation.h>
#import "Node.h"

#pragma mark protocols

@protocol CacheProtocol <NSObject>

/*!
 This function is used to cache value against a uniquely identifying key.
 @param value Value that needs to be cached

 @param key Key that needs to be used for retrieval

 @return returns a YES, if the data was properly cached else NO.
 */
- (BOOL) cacheValue:(Value*) value forKey:(NSString*)key;


/*!
 This function is used to cache value against a uniquely identifying key. The real caching happens in a different thread.
 @param value Value that needs to be cached
 
 @param key Key that needs to be used for retrieval
 
 @return returns a YES, if the data was properly cached else NO.
 */
- (void) cacheAsyncValue:(Value*) value forKey:(NSString*)key;


/*!
 This method will retrieve the cached value against key. If the value is not present in memory,
 it will look out in the mirrored and then the fallback cache.

 @param key NSString type for which the cached value needs to be retrieved

 @return Retrieved cached value as Node. It returns nil if no cached value is found.
 */
- (Value*) getValueForKey:(NSString*) key;

/*!
 This method will clear all values from this cache and the mirrored and fallback cache in a cascading manner. This would be a blocking call
 */
- (void) clearCacheAndCascade;

@end

@protocol CacheAlgorithmProtocol <NSObject>

@required

/*!
 @param node Node type that needs to be cached
 */
- (NSArray*) cacheNode: (Node*) node error:(NSError **)outError;

/*!
 This method will retrieve the cached value against key. If the value is not present in memory,
 it will look out in mirrored or fallback cache in cascading manner.
 
 @param key String value for which the cached value needs to be retrieved
 
 @return Retrieved cached value as Node. It returns nil if no cached value is found.
 */
- (Node*) getNodeForKey:(NSString*) key;

/*!
 This method will clear all values from cache
 */
- (void) clearCache;

@end

#pragma mark classes

@interface BaseCache : NSObject <CacheProtocol, CacheAlgorithmProtocol>

/*!
 Holds the fallback cache
 */
@property (nonatomic, strong) BaseCache* overFlowCache;

/*!
 Holds the mirrored cache
 */
@property (nonatomic, strong) BaseCache* mirroredCache;

@end