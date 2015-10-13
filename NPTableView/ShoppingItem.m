//
//  ShoppingItem.m
//  NPTableView
//
//  Created by User on 13/10/15.
//  Copyright © 2015 ArcTech. All rights reserved.
//

#import "ShoppingItem.h"

@implementation ShoppingItem

@synthesize itemName = _itemName;
@synthesize itemQantity = _itemQantity;

- (id)initWithName:(NSString *)name AndQantity:(NSUInteger)qantity{
    
    if(self = [super init]){
        
        _itemName = name;
        _itemQantity = qantity;
    }
    
    return self;
}

+(id)shoppingItemWithName:(NSString *)name AndQantity:(NSUInteger)qantity{
    
    return [[ShoppingItem alloc] initWithName:name AndQantity:qantity];
}

@end
