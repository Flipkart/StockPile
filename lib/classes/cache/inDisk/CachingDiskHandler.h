//
//  CachingDiskHandler.h
//  Pods
//
//  Created by Prabodh Prakash on 04/09/15.
//
//

#import <Foundation/Foundation.h>
#import "Node.h"
#import "BaseCache.h"

/*!
 It inherits from BaseCache and is used to save data to disk.
 */
@interface CachingDiskHandler : BaseCache

/*!
 The path at which data must be stored.
 */
@property (nonatomic, copy) NSString* filePath;
/*!
 The maximum element that can be used to store elements
 */
@property (nonatomic, assign) NSInteger maxElementsInMemory;

/*!
 The maximum memory that can be used to store elements
 */
@property (nonatomic, assign) NSInteger maxMemoryAllocated;

@end
