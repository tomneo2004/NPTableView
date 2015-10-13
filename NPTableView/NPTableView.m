//
//  NPTableView.m
//  NPTableView
//
//  Created by User on 12/10/15.
//  Copyright © 2015 ArcTech. All rights reserved.
//

#import "NPTableView.h"
#import "NPTableCellView.h"

@implementation NPTableView{
    
    //scrollView that is used to render cell
    UIScrollView *_scrollView;
    
    //hold all cell controllers that is currently display on scrollView
    NSMutableSet *_visibleCells;
    
    //hold all cell controllers that is recycled
    NSMutableSet *_recycledCells;
    
    //this is used to prevent tableView reload data multiple time
    //when first time view is display layoutSubViews get call at least twice
    //therefore this flag can prevent tableView reload data multiple time
    BOOL _shouldRefreshView;
    
    //hold all object that want to listen event from UIScrollView
    NSMutableSet<id<UIScrollViewDelegate>> *_uiscrollViewDelegateListener;
    
    //determine table should set default cell height
    //default cell height is base on the cell height layout
    BOOL _shouldSetDefaultCellHeight;
    
    //cell height
    CGFloat _defaultCellHeight;
}

@synthesize dataSourceDelegate = _dataSourceDelegate;

#pragma mark - override
- (id)initWithCoder:(NSCoder *)aDecoder{
    
    self = [super initWithCoder:aDecoder];
        
        if(self){
            
            //create scrollView
            _scrollView = [[UIScrollView alloc] initWithFrame:CGRectNull];
            
            //set scrollView delegate
            _scrollView.delegate = self;
            
            //add scrollView to this view
            [self addSubview:_scrollView];
            
            //init visible cell controller set
            _visibleCells = [[NSMutableSet alloc] init];
            
            //init recycle cell controller set
            _recycledCells = [[NSMutableSet alloc] init];
            
            //init uiscrollView delegate listeners
            _uiscrollViewDelegateListener = [[NSMutableSet alloc] init];
            
            //make sure tableView refresh in the beginning
            _shouldRefreshView = YES;
            
            //make sure we set default cell height at first time
            _shouldSetDefaultCellHeight = YES;
        }
    
    return self;
}

- (void)layoutSubviews{
    
    //adjust scrollView's frame to this view's bounds
    _scrollView.frame = CGRectMake(0.0f, 0.0f, self.bounds.size.width, self.bounds.size.height);
    
    
    //ask delegate for tableView bounces
    if([_dataSourceDelegate respondsToSelector:@selector(tableViewBounces)]){
        
        _scrollView.bounces = [_dataSourceDelegate tableViewBounces];
    }
    else{
        
        _scrollView.bounces = YES;
    }
    
    //ask delegate for tableView always bounces vertical
    if([_dataSourceDelegate respondsToSelector:@selector(tableViewAlwaysBouncesVertical)]){
        
        _scrollView.alwaysBounceVertical = [_dataSourceDelegate tableViewAlwaysBouncesVertical];
    }
    else{
        
        _scrollView.alwaysBounceVertical = YES;
    }
    
    //ask delegate for tableView background color
    if([_dataSourceDelegate respondsToSelector:@selector(tableViewBackgroundColor)]){
        
        self.backgroundColor = [_dataSourceDelegate tableViewBackgroundColor];
    }
    else{
        
        self.backgroundColor = [UIColor whiteColor];
    }
    
    //ask delegate for scrollView's background color
    if([_dataSourceDelegate respondsToSelector:@selector(tableScrollableViewBackgroundColor)]){
        
        _scrollView.backgroundColor = [_dataSourceDelegate tableScrollableViewBackgroundColor];
    }
    else{
        
        _scrollView.backgroundColor = [UIColor whiteColor];
    }
    
    //set default cell height
    if(_shouldSetDefaultCellHeight){
        
        //ask delegate for cell's class and turn it into string
        NSString *className = NSStringFromClass([_dataSourceDelegate cellClass]);
        
        //if there is a xib file name match cell's class name then use xib view's height as default
        //otherwise set it to 60
        if([[NSBundle mainBundle] pathForResource:className ofType:@"xib"]){
            
            //get xib file
            NSArray *nibContents = [[NSBundle mainBundle] loadNibNamed:className owner:self options:nil];
            
            //get view
            UIView *view = [nibContents objectAtIndex:0];
            
            //use xib view's height as default height
            _defaultCellHeight = view.bounds.size.height;
        }
        else{
            
            _defaultCellHeight = 60;
        }
        
        
        _shouldSetDefaultCellHeight = NO;
    }
    
    //if we need to refresh tableView
    if(_shouldRefreshView){
        
        _shouldRefreshView = NO;
        [self refreshView];
    }
}

#pragma mark - getter
- (UIScrollView *)getScrollView{
    
    return _scrollView;
}

#pragma mark - public interface
- (void)addListenerForScrollViewDelegate:(id<UIScrollViewDelegate>)listener{
    
    [_uiscrollViewDelegateListener addObject:listener];
}

- (void)removeListenerForScrollViewDelegate:(id<UIScrollViewDelegate>)listener{
    
    [_uiscrollViewDelegateListener removeObject:listener];
}

- (NPTableCellView *)dequeueReusableCell{
    
    NPTableCellView *cell;
    
    //if there is at least one cell controller in recycled set
    if(_recycledCells.count > 0){
        
        cell = [_recycledCells anyObject];
        
        //remove from recycle set
        [_recycledCells removeObject:cell];
        
        return cell;
    }
    
    return nil;
}

- (NSArray *)visibleCells{
    
    NSMutableArray *cells = [[NSMutableArray alloc] init];
    
    for(NPTableCellView *cell in _visibleCells){
        
        [cells addObject:cell];
    }
    
    //sort cell controller by compare thier view's origin y
    NSArray *sortedCellControllers = [cells sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2){
    
        NPTableCellView *cell1 = obj1;
        NPTableCellView *cell2 = obj2;
        
        float result = cell2.frame.origin.y - cell1.frame.origin.y;
        
        if(result > 0.0){
            
            return NSOrderedAscending;
        }
        else if(result < 0.0){
            
            return NSOrderedDescending;
        }
        else{
            
            return NSOrderedSame;
        }
    }];
    
    return sortedCellControllers;
}

- (NSArray *)recycledCells{
    
    return [_recycledCells allObjects];
}

- (void)reloadData{
    
    //recycle all cell controllers
    NSArray *visibleCells = [_visibleCells allObjects];
    [self recycleCells:visibleCells];
    
    //refresh view
    [self refreshView];
}

#pragma mark - internal
- (void)refreshView{
    
    if(CGRectIsNull(_scrollView.frame)){
        
        return;
    }
    
    //set scrollView's content size
    _scrollView.contentSize = CGSizeMake(_scrollView.bounds.size.width, [_dataSourceDelegate numberOfRows] * [self cellHeight]);
    
    
    //check if any cell need to be recycle
    NSMutableArray *recycledCells = [[NSMutableArray alloc] init];
    
    for(NPTableCellView * cell in _visibleCells){
        
        if((cell.frame.origin.y + cell.frame.size.height) < _scrollView.contentOffset.y){
            
            [recycledCells addObject:cell];
        }
        
        if(cell.frame.origin.y > (_scrollView.contentOffset.y + _scrollView.bounds.size.height) + [self cellHeight]){
            
            [recycledCells addObject:cell];
        }
    }
    
    if(recycledCells.count > 0){
        
        [self recycleCells:recycledCells];
    }
    

    //display visible cell, we find first visible cell index and last visible cell index
    int firstVisibleIndex = MAX(0, floor(_scrollView.contentOffset.y / [self cellHeight]));
    int lastvisibleIndex = MIN([_dataSourceDelegate numberOfRows], firstVisibleIndex + 1 + ceil(_scrollView.bounds.size.height / [self cellHeight]));
    
    for(int row = firstVisibleIndex; row<lastvisibleIndex; row++){
        
        //check if current row is already in visible cell controller, if so just leave it be
        NPTableCellView *cell = [self visibleCellForRow:row];
        
        //if current row is not in visible cell, we ask delegate for cell controller
        if(!cell){
            
            //ask delegate for cell controller
            cell = [_dataSourceDelegate cellForRow:row];
            
            //find top edge y positioin for this cell row
            float topEdgeForRow = row * [self cellHeight];
            
            //adjust cell's frame
            cell.frame = CGRectMake(0, topEdgeForRow, _scrollView.bounds.size.width, [self cellHeight]);
            
            //add to scrollView
            [_scrollView insertSubview:cell atIndex:0];
            
            
            //add cell controller to visible cell controllers
            [_visibleCells addObject:cell];
        }
    }
    
}

- (void)recycleCell:(NPTableCellView *)cell{
    
    [cell removeFromSuperview];
    
    [_recycledCells addObject:cell];
    [_visibleCells removeObject:cell];
    
}

- (void)recycleCells:(NSArray *)cells{
    
    [cells makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    [_recycledCells addObjectsFromArray:cells];
    [_visibleCells minusSet:[NSSet setWithArray:cells]];
    
}

- (CGFloat)cellHeight{
    
    if([_dataSourceDelegate respondsToSelector:@selector(cellHeight)]){
        
        return [_dataSourceDelegate cellHeight];
    }
    
    return _defaultCellHeight;
}

- (NPTableCellView *)visibleCellForRow:(int)row{
    
    //find top edge y position for specific row
    float topEdgeForRow = row * [self cellHeight];
    
    //go through all visible cell controllers and find the cell controller
    for(NPTableCellView *cell in _visibleCells){
        
        if(cell.frame.origin.y == topEdgeForRow){
            
            return cell;
        }
    }
    
    return nil;
}

#pragma mark - UIScrollView delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    [self refreshView];
    
    //propagate event to all delegate listener
    if(_uiscrollViewDelegateListener != nil){
        
        for(id<UIScrollViewDelegate> go in _uiscrollViewDelegateListener){
            
            if([go respondsToSelector:@selector(scrollViewDidScroll:)]){
                
                [go scrollViewDidScroll:scrollView];
            }
        }
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
