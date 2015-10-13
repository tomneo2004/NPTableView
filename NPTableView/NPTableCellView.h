//
//  NPTableCellController.h
//  NPTableView
//
//  Created by User on 12/10/15.
//  Copyright © 2015 ArcTech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NPTableView.h"

@interface NPTableCellView : UIView

/**
 * Create a cell
 * You can first create and design cell in xib file.
 * Then you can use this method and give xib file name to create cell
 */
- (id)initWithNibName:(NSString *)nibName;

@end
