//
//  CachingInMemoryHandler.h
//  Pods
//
//  Created by Prabodh Prakash on 01/09/15.
//
//

#import <Foundation/Foundation.h>
#import "Node.h"
#import "BaseCache.h"

/*!
 This class provides standard implementation of LRU Cache.
 */
@interface CachingInMemoryHandler : BaseCache

/*!
 The maximum number of elements that can be stored in memory.
 */
@property (nonatomic, assign) NSInteger maxElementsInMemory;

/*!
 The maximum memory that can be used to store elements
 */
@property (nonatomic, assign) float maxMemoryAllocated;

@end
