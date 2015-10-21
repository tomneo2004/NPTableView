//
//  ViewController.m
//  NPTableView
//
//  Created by User on 12/10/15.
//  Copyright © 2015 ArcTech. All rights reserved.
//

#import "ViewController.h"


@interface ViewController ()

@property (weak, nonatomic) IBOutlet NPTableView *tableView;

@end

@implementation ViewController{
    
    NSMutableArray *shoppingItems;
}

@synthesize tableView = _tableView;

#pragma mark - override
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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
    
    //add single tap gesture component
    SingleTap *tap = [[SingleTap alloc] initWithTableView:_tableView WithPriority:0];
    tap.delegate = self;
    [_tableView addGestureComponent:tap];
    
    //add double tap gesture component
    DoubleTap *doubleTap = [[DoubleTap alloc] initWithTableView:_tableView WithPriority:0];
    doubleTap.delegate = self;
    [_tableView addGestureComponent:doubleTap];
    
    //single tap happen when double tap fail
    [tap requireGestureComponentToFail:doubleTap];
    
    //add long press
    LongPress * longPress = [[LongPress alloc] initWithTableView:_tableView WithPriority:0];
    longPress.delegate = self;
    [_tableView addGestureComponent:longPress];
    
    //add pull down add new
    PullDownAddNew *pDAN = [[PullDownAddNew alloc] initWithTableView:_tableView WithPriority:0];
    pDAN.delegate = self;
    [_tableView addGestureComponent:pDAN];
    
}

#pragma mark - PanleftRight delegate
//handle panning left
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

//handle panning right
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

- (void)onPanLeftAtCellIndex:(NSInteger)index{
    
    ShoppingItem *deleteItem = [shoppingItems objectAtIndex:index];
    
    [shoppingItems removeObjectAtIndex:index];
    
    float delay = 0.0;
    
    NSArray *visibleCells = [_tableView visibleCells];
    
    UIView *lastView = [visibleCells lastObject];
    
    BOOL startAnimating  = NO;
    
    //shuffle cell up
    for(ShoppingItemCell *cell in visibleCells){
        
        if (startAnimating) {
            [UIView animateWithDuration:0.3
                                  delay:delay
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 cell.frame = CGRectOffset(cell.frame, 0.0f, -cell.frame.size.height);
                             }
                             completion:^(BOOL finished){
                                 if (cell == lastView) {
                                     [self.tableView reloadData];
                                 }
                             }];
            delay+=0.03;
        }
        
        // if you have reached the item that was deleted, start animating
        if (cell.item == deleteItem) {
            startAnimating = true;
            cell.hidden = YES;
        }
    }
    
    
    if(((ShoppingItemCell *)lastView).item == deleteItem){
        
        [_tableView reloadData];
    }

    
}

- (void)onPanRightAtCellIndex:(NSInteger)index{
    
}

#pragma mark - SingleTap delegate
- (void)onSingleTapAtCellIndex:(NSInteger)index{
    
    NSLog(@"Tap on cell at index: %li", (long)index);
}

#pragma mark - DoubleTap delegate
- (void)onDoubleTapAtCellIndex:(NSInteger)index{
    
    NSLog(@"Double tap on cell at index: %li", (long)index);
}

#pragma mark - LongPress delegate
- (void)onLongPressAtCellIndex:(NSInteger)index{
    
    NSLog(@"Long press on cell at index: %li", (long)index);
}

#pragma mark - PullDownAddNew delegate
- (void)addNewItemWithText:(NSString *)text{
    
    ShoppingItem *newItem = [ShoppingItem shoppingItemWithName:text AndQantity:0];
    
    [shoppingItems insertObject:newItem atIndex:0];
    
    [_tableView reloadData];
}

#pragma mark - NPTableView delegate
- (NSInteger)numberOfRows{
    
    return shoppingItems.count;
}

- (NPTableCellView *)tableView:(NPTableView *)tableView cellForRow:(NSInteger)row{
    
    ShoppingItemCell *cell = (ShoppingItemCell *)[tableView dequeueReusableCell];
    
    if(cell == nil){
        
        cell = [ShoppingItemCell cellWithNibName:@"ShoppingItemCell"];
        //cell = [[ShoppingItemCell alloc] initWithNibName:@"ShoppingItemCell"];
        
        //give a select background
        UIView *bgView = [[UIView alloc] init];
        bgView.backgroundColor = [UIColor yellowColor];
        cell.selectBackgroundView = bgView;
    }
    
    ShoppingItem *item = [shoppingItems objectAtIndex:row];
    
    cell.item = item;
    cell.itemNameLabel.text = item.itemName;
    cell.itemQantityLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)item.itemQantity];
    
    cell.backgroundColor = [UIColor clearColor];
    
    return cell;
}

- (Class)cellClass{
    
    return [ShoppingItemCell class];
}

//uncomment to use code to define cell height
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

- (BOOL)enableVerticalScrollIndicator{
    
    return YES;
}

- (UIColor *)tableViewBackgroundColor{
    
    return [UIColor clearColor];
}

- (UIColor *)tableScrollableViewBackgroundColor{
    
    return [UIColor clearColor];
}

@end
