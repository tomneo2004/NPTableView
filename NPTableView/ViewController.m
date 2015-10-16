//
//  ViewController.m
//  NPTableView
//
//  Created by User on 12/10/15.
//  Copyright © 2015 ArcTech. All rights reserved.
//

#import "ViewController.h"
#import "PanLeftRight.h"


@interface ViewController ()

@property (weak, nonatomic) IBOutlet NPTableView *tableView;

@end

@implementation ViewController{
    
    NSMutableArray *shoppingItems;
}

@synthesize tableView = _tableView;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    shoppingItems = [[NSMutableArray alloc] init];
    
    [shoppingItems addObject:[ShoppingItem shoppingItemWithName:@"Apple" AndQantity:2]];
    [shoppingItems addObject:[ShoppingItem shoppingItemWithName:@"Pistol" AndQantity:20]];
    [shoppingItems addObject:[ShoppingItem shoppingItemWithName:@"C4" AndQantity:1]];
    [shoppingItems addObject:[ShoppingItem shoppingItemWithName:@"Beef" AndQantity:4]];
    [shoppingItems addObject:[ShoppingItem shoppingItemWithName:@"Glue" AndQantity:67]];
    [shoppingItems addObject:[ShoppingItem shoppingItemWithName:@"7.76mmAmmo" AndQantity:2000]];
    [shoppingItems addObject:[ShoppingItem shoppingItemWithName:@"5.56mmAmmo" AndQantity:10000]];
    [shoppingItems addObject:[ShoppingItem shoppingItemWithName:@"Grenade" AndQantity:23]];
    [shoppingItems addObject:[ShoppingItem shoppingItemWithName:@"Helmet" AndQantity:7]];
    [shoppingItems addObject:[ShoppingItem shoppingItemWithName:@"Bike" AndQantity:9]];
    [shoppingItems addObject:[ShoppingItem shoppingItemWithName:@"pan" AndQantity:44]];
    [shoppingItems addObject:[ShoppingItem shoppingItemWithName:@"Bra" AndQantity:57]];
    [shoppingItems addObject:[ShoppingItem shoppingItemWithName:@"Car" AndQantity:1]];
    [shoppingItems addObject:[ShoppingItem shoppingItemWithName:@"Weed" AndQantity:300]];
    [shoppingItems addObject:[ShoppingItem shoppingItemWithName:@"Shotgun" AndQantity:33]];
    [shoppingItems addObject:[ShoppingItem shoppingItemWithName:@"Cable" AndQantity:54]];
    [shoppingItems addObject:[ShoppingItem shoppingItemWithName:@"Girl" AndQantity:68]];
    [shoppingItems addObject:[ShoppingItem shoppingItemWithName:@"Man" AndQantity:19]];
    
    _tableView.dataSourceDelegate = self;
   
    //add PanDeleteComplete gesture component
    PanLeftRight *panLRCom = [[PanLeftRight alloc] initWithTableView:_tableView WithPriority:0];
    panLRCom.panRightSnapBackAnim = YES;
    panLRCom.panLeftSnapBackAnim = YES;
    panLRCom.delegate = self;
    [_tableView addGestureComponent:panLRCom];
}

- (void)onPanningLeftWithDelta:(CGFloat)delta AtCellIndex:(NSInteger)index{
    
    ShoppingItemCell *cell = (ShoppingItemCell *)[_tableView findCellInVisibleCellsByIndex:index];
    
    cell.deleteLabel.alpha = delta;
    
    if(delta >= 1){
        
        cell.deleteLabel.textColor = [UIColor redColor];
    }
    else{
        
        cell.deleteLabel.textColor = [UIColor whiteColor];
    }
}

- (void)onPanningRightWithDelta:(CGFloat)delta AtCellIndex:(NSInteger)index{
    
    ShoppingItemCell *cell = (ShoppingItemCell *)[_tableView findCellInVisibleCellsByIndex:index];
    
    cell.completeLabel.alpha = delta;
    
    if(delta >= 1){
        
        cell.completeLabel.textColor = [UIColor greenColor];
    }
    else{
        
        cell.completeLabel.textColor = [UIColor whiteColor];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfRows{
    
    return shoppingItems.count;
}

- (NPTableCellView *)tableView:(NPTableView *)tableView cellForRow:(NSInteger)row{
    
    ShoppingItemCell *cell = (ShoppingItemCell *)[tableView dequeueReusableCell];
    
    if(cell == nil){
        
        cell = [[ShoppingItemCell alloc] initWithNibName:@"ShoppingItemCell"];
    }
    
    ShoppingItem *item = [shoppingItems objectAtIndex:row];
    
    cell.itemNameLabel.text = item.itemName;
    cell.itemQantityLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)item.itemQantity];
    
    cell.backgroundColor = [UIColor clearColor];
    
    return cell;
}

- (Class)cellClass{
    
    return [ShoppingItemCell class];
}

/*
- (CGFloat)cellHeight{
    
    return 60.0f;
}
*/

- (BOOL)tableViewBounces{
    
    return YES;
    
}

- (BOOL)tableViewAlwaysBouncesVertical{
    
    return YES;
    
}

- (UIColor *)tableViewBackgroundColor{
    
    return [UIColor clearColor];
}

- (UIColor *)tableScrollableViewBackgroundColor{
    
    return [UIColor clearColor];
}

@end
