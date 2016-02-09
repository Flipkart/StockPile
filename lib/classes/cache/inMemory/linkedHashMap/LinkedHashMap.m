//
//  LinkedHashMap.m
//  Pods
//
//  Created by Prabodh Prakash on 01/09/15.
//
//

#import "LinkedHashMap.h"
#import "CachingException.h"

@interface LinkedHashMap()

@property (nonatomic, strong) NSMutableDictionary* lookupDictionary;
@property (nonatomic, strong) Node* startNode;
@property (nonatomic, strong) Node* endNode;

@end

@implementation LinkedHashMap

- (instancetype) init
{
    self = [super init];
    
    if (self)
    {
        _startNode = nil;
        _endNode = nil;
        _lookupDictionary = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

- (BOOL) containsValue: (Node*) node
{
    id<NSCopying, NSMutableCopying, NSSecureCoding> key = node.key;
    
    if ([_lookupDictionary objectForKey:key] != nil)
    {
        return true;
    }
    
    return false;
}

- (Node*) getObject: (NSString*) key
{
    Node* node = [_lookupDictionary objectForKey:key];
    
    return node;
}

- (void) clear
{
    _startNode = nil;
    _endNode = nil;
    
    [_lookupDictionary removeAllObjects];
}

- (void) putNode: (Node*) node
{
    if (node == nil)
    {
        @throw [[CachingException alloc] initWithReason:@"Node to be inserted cannot be nil"];
    }
    
    id<NSCopying, NSMutableCopying, NSSecureCoding> key = node.key;
    
    [_lookupDictionary setObject:node forKey:key];
    
    if (_startNode == nil)
    {
        _startNode = node;
        _startNode.previousNode = nil;
        _startNode.nextNode = nil;
    }
    else if (_endNode == nil)
    {
        _endNode = _startNode;
        _startNode = node;
        _endNode.previousNode = _startNode;
        _startNode.nextNode = _endNode;
        _endNode.nextNode = nil;
    }
    else
    {
        node.nextNode = _startNode;
        node.previousNode = nil;
        _startNode.previousNode = node;
        _startNode = node;
    }
}

- (void) putNode: (Node*) node atIndex: (int) index
{
    id<NSCopying, NSMutableCopying, NSSecureCoding> key = node.key;
    
    [_lookupDictionary setObject:node forKey:key];
    
    [self moveNode:node toPosition:index];
}

- (void) moveNode: (Node*) node toPosition:(int) index
{
    Node* root = _startNode;
    int count = 0;
    
    while (count++ != index)
    {
        root = root.nextNode;
    }
    
    if (root == node)
    {
        return;
    }
    
    //deleting node from its original position
    node.previousNode.nextNode = node.nextNode;
    
    //case when node is the last node
    if (node.nextNode == nil)
    {
        _endNode = node.previousNode;
    }
    
    node.nextNode.previousNode = node.previousNode;
    
    node.previousNode = nil;
    node.nextNode = nil;
    
    //adding node to its new position
    root.previousNode.nextNode = node;
    
    if (root.previousNode == nil)
    {
        _startNode = node;
    }
    
    node.previousNode = root.previousNode;
    
    node.nextNode = root;
    root.previousNode = node;
    
    root = _startNode;
}

- (void) removeNodeWithKey: (NSString*) key
{
    Node* node = [_lookupDictionary objectForKey:key];
    
    if (node == nil)
    {
        return;
    }
    
    [_lookupDictionary removeObjectForKey:key];
    
    node.previousNode.nextNode = node.nextNode;
    node.nextNode.previousNode = node.previousNode;
}

- (Node*) removeEndNode
{
    if (_endNode == nil)
    {
        return nil;
    }
    
    Node* returnNode = _endNode;
    
    id<NSCopying, NSMutableCopying, NSSecureCoding> key = _endNode.key;
    
    [_lookupDictionary removeObjectForKey:key];
    
    _endNode.previousNode.nextNode = nil;
    
    _endNode = _endNode.previousNode;
    
    return returnNode;
}

@end