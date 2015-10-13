//
//  ShoppingItem.h
//  NPTableView
//
//  Created by User on 13/10/15.
//  Copyright © 2015 ArcTech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ShoppingItem : NSObject

@property (copy, nonatomic)NSString *itemName;
@property (assign, nonatomic)NSUInteger itemQantity;

+(id)shoppingItemWithName:(NSString *)name AndQantity:(NSUInteger)qantity;

@end
