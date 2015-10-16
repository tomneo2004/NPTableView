//
//  ShoppingItemCellController.m
//  NPTableView
//
//  Created by User on 13/10/15.
//  Copyright © 2015 ArcTech. All rights reserved.
//

#import "ShoppingItemCell.h"

@interface ShoppingItemCell ()

@end

@implementation ShoppingItemCell

@synthesize itemNameLabel = _itemNameLabel;
@synthesize itemQantityLabel = _itemQantityLabel;
@synthesize completeLabel = _completeLabel;
@synthesize deleteLabel = _deleteLabel;

- (void)layoutSubviews{
    
    [super layoutSubviews];
    
    _completeLabel.text = @"\u2713";
    _deleteLabel.text = @"\u2717";
}

@end
