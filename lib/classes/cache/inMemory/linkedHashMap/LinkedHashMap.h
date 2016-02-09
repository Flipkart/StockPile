//
//  LinkedHashMap.h
//  Pods
//
//  Created by Prabodh Prakash on 01/09/15.
//
//

#import <Foundation/Foundation.h>
#import "Node.h"

/*!
    @brief This class is a data strcutre that holds value in a doubly linked list and uses NSDictionary for
    O(1) retrival of data.
 
    @discussion This data stucture is used to store values in a doubly linked list and retrival is done using
    NSDictionary. All the new nodes gets appended to the start of the linked list.
 */
@interface LinkedHashMap : NSObject

/*!
    This function checks and returns a BOOL value that tells if a node is present in the doubly linked list or not.
    
    @param node the node which needs to be checked for its presence in linked list.
    @return returns YES, if the node exist, otherwise NO
 */
- (BOOL) containsValue: (Node*) node;

/*!
    This function returns a Node object for the key passed in parameters
 
    @param key NSString against which the Node has to be returned
 
    @return The node associated with key or nil.
 */
- (Node*) getObject: (NSString*) key;

/*!
    It clears all the values.
 */
- (void) clear;

/*!
    This function adds the node at the start of the linked list
    
    @param node that needs to be added to the linked list.
 */
- (void) putNode: (Node*) node;

/*!
    This function adds the node at a specific position in the linked list
 
    @param node that needs to be added to the linked list.
 
    @param index index at which the node needs to be added.
 */
- (void) putNode: (Node*) node atIndex: (int) index;

/*!
    This function moves a node from its position to a specified index.
 
    @param node that needs to be moved
 
    @param index the final position of the node.
 */
- (void) moveNode: (Node*) node toPosition:(int) index;

/*!
 This function removes a node with a key.
 
 @param key identifies the node that needs to be removed.
 */
- (void) removeNodeWithKey: (NSString*) key;

/*!
 This function removes the last node.
 */
- (Node*) removeEndNode;

@end