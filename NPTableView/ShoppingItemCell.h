//
//  ShoppingItemCellController.h
//  NPTableView
//
//  Created by User on 13/10/15.
//  Copyright © 2015 ArcTech. All rights reserved.
//

#import "NPTableCellView.h"

@interface ShoppingItemCell : NPTableCellView

@property (weak, nonatomic) IBOutlet UILabel *itemNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *itemQantityLabel;

@end
