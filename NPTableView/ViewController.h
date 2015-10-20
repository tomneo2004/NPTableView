//
//  ViewController.h
//  NPTableView
//
//  Created by User on 12/10/15.
//  Copyright © 2015 ArcTech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PanLeftRight.h"
#import "SingleTap.h"
#import "DoubleTap.h"
#import "ShoppingItem.h"
#import "NPTableView.h"
#import "ShoppingItemCell.h"

@interface ViewController : UIViewController<NPTableViewDataSource, PanLeftRightDelegate, SingleTapDelegate, DoubleTapDelegate>


@end

