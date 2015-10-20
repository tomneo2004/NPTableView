//
//  ShoppingItemCellController.h
//  NPTableView
//
//  Created by User on 13/10/15.
//  Copyright © 2015 ArcTech. All rights reserved.
//

#import "NPTableCellView.h"
#import "ShoppingItem.h"

@interface ShoppingItemCell : NPTableCellView

@property (nonatomic) ShoppingItem *item;
@property (weak, nonatomic) IBOutlet UILabel *itemNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *itemQantityLabel;
@property (weak, nonatomic) IBOutlet UILabel *completeLabel;
@property (weak, nonatomic) IBOutlet UILabel *deleteLabel;

@end
