//
//  NPTableView.h
//  NPTableView
//
//  Created by User on 12/10/15.
//  Copyright © 2015 ArcTech. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NPTableCellView;

@protocol NPTableViewDataSource <NSObject>

@required
/**
 * Number of row in the table
 */
- (NSInteger)numberOfRows;

/**
 * Cell controller for specific row
 */
- (NPTableCellView *)cellForRow:(NSInteger)row;

/**
 * Cell's class.
 * This is used to get default height of cell from xib file
 * which user designed cell layout in.
 * If there is no xib file then default height of cell is 60
 */
- (Class)cellClass;


@optional
/**
 * Height of cell, if not override then layout cell height will be default
 */
- (CGFloat)cellHeight;

/**
 * Return Yes if tableView should bounces,
 * otherwise No
 */
- (BOOL)tableViewBounces;

/**
 * Return Yes if tableView should always bounces vertical,
 * otherwise No
 */
- (BOOL)tableViewAlwaysBouncesVertical;

/**
 * TableView's background color, default is white
 * If this view is first layer of application then return
 * clear color might not work as expect
 */
- (UIColor *)tableViewBackgroundColor;

/**
 * TableView's scrollView background color
 */
- (UIColor *)tableScrollableViewBackgroundColor;

@end

@interface NPTableView : UIView<UIScrollViewDelegate>

/**
 * The object that conform to DataSourceDelegate
 */
@property (weak, nonatomic) id<NPTableViewDataSource> dataSourceDelegate;

/**
 * The ScrollView that used to render cell
 */
@property (getter=getScrollView, nonatomic) UIScrollView *scrollView;

/**
 * Dequeue reusable/recycled cell controller.
 * Return nil if there is no resuable/recycled cell controller
 */
- (NPTableCellView *)dequeueReusableCell;

/**
 * All cell controllers that are currently display on tableView
 */
- (NSArray *)visibleCells;

/**
 * All recycled cell controllers
 */
- (NSArray *)recycledCells;

/**
 * Reload tableView's data, tableView will rebuild
 */
- (void)reloadData;

- (void)addListenerForScrollViewDelegate:(id<UIScrollViewDelegate>)listener;

- (void)removeListenerForScrollViewDelegate:(id<UIScrollViewDelegate>)listener;

@end
