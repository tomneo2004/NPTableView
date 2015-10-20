//
//  NPTableView.m
//  NPTableView
//
//  Created by User on 12/10/15.
//  Copyright © 2015 ArcTech. All rights reserved.
//

#import "NPTableView.h"
#import "NPTableCellView.h"
#import "GestureComponent.h"
#import "NPScrollView.h"

@implementation NPTableView{
    
    //scrollView that is used to render cell
    NPScrollView *_scrollView;
    
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
    
    //hold all gesture components
    NSMutableArray *_gestureComponents;
    
    //temp selected cell
    __weak NPTableCellView *_tempCell;
    
    //used to determine if a cell is touched
    //used to setSelect cell and setHighlight cell
    BOOL _didTouchCell;
    
    //began of touch location;
    //used to find out which cell is touched
    //used to setSelect cell and setHighlight cell
    CGPoint _beganTouchLocation;
    
    //if finger move distance within dead zone it consider not moving
    //otherwise move
    //used to setSelect cell and setHighlight cell
    CGFloat _deadzoneRadius;
    
    //determine whether tableView can be interacted
    BOOL _interactionEnable;
}

@synthesize dataSourceDelegate = _dataSourceDelegate;

#pragma mark - override
- (id)initWithCoder:(NSCoder *)aDecoder{
    
    self = [super initWithCoder:aDecoder];
        
        if(self){
            
            _interactionEnable = YES;
            
            //create scrollView
            _scrollView = [[NPScrollView alloc] initWithFrame:CGRectNull];

            //setup touch dead zone
            _deadzoneRadius = 0.5f;
            
            _didTouchCell = NO;
            
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
            
            //init gesture components array
            _gestureComponents = [[NSMutableArray alloc] init];
            
            //make sure tableView refresh in the beginning
            _shouldRefreshView = YES;
            
            //make sure we set default cell height at first time
            _shouldSetDefaultCellHeight = YES;
            
            [[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(deviceOrientationDidChange:) name: UIDeviceOrientationDidChangeNotification object: nil];
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
    
    //ask delegate for scrollView vertical scroll indicator
    if([_dataSourceDelegate respondsToSelector:@selector(enableVerticalScrollIndicator)]){
        
        _scrollView.showsVerticalScrollIndicator = [_dataSourceDelegate enableVerticalScrollIndicator];
    }
    else{
        
        _scrollView.showsVerticalScrollIndicator = YES;
    }
    
    //set default cell height
    if(_shouldSetDefaultCellHeight){
        
        //ask delegate for cell's class and turn it into string
        NSString *className = NSStringFromClass([_dataSourceDelegate cellClass]);
        
        //if there is a xib file name match cell's class name then use xib view's height as default
        //otherwise set it to 60
        if([[NSBundle mainBundle] pathForResource:className ofType:@"nib"]){
            
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

/**
 * override touchBegan to handle setSelect cell
 */
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    if(!_interactionEnable)
        return;
        
    _beganTouchLocation = [[touches anyObject] locationInView:_scrollView];
    
    //give a delay to begin select cell
    //during this time if user move finger then it should cancel select cell
    [self performSelector:@selector(beginSelectCellWithTouch) withObject:nil afterDelay:0.01f];
}

/**
 * override touchesMoved to handle whether setSelect cell should happen or not
 */
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    if(!_interactionEnable)
        return;
    
    CGPoint cTouch = [[touches anyObject] locationInView:_scrollView];
    CGFloat moveDistance = sqrt(pow(cTouch.x-_beganTouchLocation.x, 2)+pow(cTouch.y-_beganTouchLocation.y, 2));
    
    //if greater then dead zone radius we do not select cell
    if(moveDistance > _deadzoneRadius){
        
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    if(!_interactionEnable)
        return;
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    [_tempCell setSelect:NO];
    
    _tempCell = nil;
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    if(!_interactionEnable)
        return;
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    [_tempCell setSelect:NO];
    
    _tempCell = nil;
}

#pragma mark - getter
- (UIScrollView *)getScrollView{
    
    return _scrollView;
}

- (NSArray *)getGestureComponents{
    
    return _gestureComponents;
}

-(CGFloat)getDefaultRowHeight{
    
    return _defaultCellHeight;
}

#pragma mark - setter
- (void)setInteractionEnable:(BOOL)interactionEnable{
    
    _interactionEnable = interactionEnable;
    
    _scrollView.scrollEnabled = _interactionEnable;
}

#pragma mark - public interface
- (void)addListenerForScrollViewDelegate:(id<UIScrollViewDelegate>)listener{
    
    [_uiscrollViewDelegateListener addObject:listener];
}

- (void)removeListenerForScrollViewDelegate:(id<UIScrollViewDelegate>)listener{
    
    [_uiscrollViewDelegateListener removeObject:listener];
}

- (void)addGestureComponent:(GestureComponent *)component{
    
    if(component == nil){
        
        NSLog(@"Add component can not be nil");
        return;
    }
    
    BOOL exist = NO;
    
    for(GestureComponent *c in _gestureComponents){
        
        if([c isKindOfClass:[component class]]){
            
            exist = YES;
            break;
        }
    }
    
    if(exist){
        
        NSLog(@"Component you add is already exist");
        return;
    }
    
    [_gestureComponents addObject:component];
    
    NSArray *sortedComponents;
    
    sortedComponents = [_gestureComponents sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2){
    
        GestureComponent *c1 = obj1;
        GestureComponent *c2 = obj2;
        
        NSInteger result = c2.priority - c1.priority;
        
        if(result > 0){
            
            return NSOrderedAscending;
        }
        else if(result < 0){
            
            return NSOrderedDescending;
        }
        else{
            
            return NSOrderedSame;
        }
    }];
    
    _gestureComponents = [[NSMutableArray alloc] initWithArray:sortedComponents];
}

- (void)removeGestureComponent:(GestureComponent *)component{
    
    if(component == nil)
        return;
    
    //remove gesture
    [_scrollView removeGestureRecognizer:component.gestureRecognizer];
    
    //remove component
    [_gestureComponents removeObject:component];
}

- (void)removeGestureComponentByClass:(Class)componentClass{
    
    GestureComponent *removedComponent;
    
    //go through gesture components and find it
    for(GestureComponent *component in _gestureComponents){
        
        if([component isKindOfClass:componentClass]){
            
            removedComponent = component;
            
            break;
        }
    }
    
    //remove it
    [self removeGestureComponent:removedComponent];
}

- (id)findGestureComponentByClass:(Class)componentClass{
    
    //go through gesture components and find it
    for(GestureComponent *component in _gestureComponents){
        
        if([component isKindOfClass:componentClass]){
            
            return component;
        }
    }
    
    return nil;
}

- (NPTableCellView *)findCellByPoint:(CGPoint)point{
    
    CGPoint adjustPoint = CGPointMake(point.x, _scrollView.contentOffset.y + point.y);
    
    for(NPTableCellView *go in _visibleCells){
        
        CGRect rect = CGRectMake(go.frame.origin.x, go.frame.origin.y + _scrollView.contentOffset.y, go.frame.size.width, go.frame.size.height);
        
        if(CGRectContainsPoint(rect, adjustPoint)){
            
            return go;
        }
    }
    
    return nil;
}

- (NSInteger)findCellIndexByPoint:(CGPoint)point{

    return floor(point.y / _defaultCellHeight);
}

- (NPTableCellView *)findCellInVisibleCellsByIndex:(NSInteger)index{
    
    for(NPTableCellView *go in _visibleCells){
        
        NSInteger cIndex = go.frame.origin.y / _defaultCellHeight;
        
        if(cIndex == index)
            return go;
    }
    
    return nil;
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
    
    _shouldRefreshView = YES;
    _shouldSetDefaultCellHeight = YES;
    
    //recycle all cell controllers
    NSArray *visibleCells = [_visibleCells allObjects];
    [self recycleCells:visibleCells];
    
    //refresh view
    [self refreshView];

}

#pragma mark - internal
- (void)beginSelectCellWithTouch{
    
    _didTouchCell = YES;
    
    _tempCell = [self findCellByPoint:_beganTouchLocation];
    
    [_tempCell setSelect:YES];
}

- (void)deviceOrientationDidChange:(NSNotification *)notification{

    [self reloadData];
}

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
            cell = [_dataSourceDelegate tableView:self cellForRow:row];
            
            //find top edge y positioin for this cell row
            float topEdgeForRow = row * [self cellHeight];
            
            //adjust cell's frame
            cell.frame = CGRectMake(0, topEdgeForRow, _scrollView.bounds.size.width, [self cellHeight]);
            
            cell.hidden = NO;
            
            //add to scrollView
            [_scrollView insertSubview:cell atIndex:0];
            
            
            //add cell controller to visible cell controllers
            [_visibleCells addObject:cell];
        }
    }
    
}

- (void)recycleCell:(NPTableCellView *)cell{
    
    [cell willRecycle];
    
    [cell removeFromSuperview];
    
    [_recycledCells addObject:cell];
    [_visibleCells removeObject:cell];
    
    [cell didRecycle];
}

- (void)recycleCells:(NSArray *)cells{
    
    [cells makeObjectsPerformSelector:@selector(willRecycle)];
    
    [cells makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    [_recycledCells addObjectsFromArray:cells];
    [_visibleCells minusSet:[NSSet setWithArray:cells]];
    
    [cells makeObjectsPerformSelector:@selector(didRecycle)];
    
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

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    
    
    //propagate event to all delegate listener
    if(_uiscrollViewDelegateListener != nil){
        
        for(id<UIScrollViewDelegate> go in _uiscrollViewDelegateListener){
            
            if([go respondsToSelector:@selector(scrollViewWillBeginDragging:)]){
                
                [go scrollViewWillBeginDragging:scrollView];
            }
        }
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{
    
    
    //propagate event to all delegate listener
    if(_uiscrollViewDelegateListener != nil){
        
        for(id<UIScrollViewDelegate> go in _uiscrollViewDelegateListener){
            
            if([go respondsToSelector:@selector(scrollViewWillEndDragging:withVelocity:targetContentOffset:)]){
                
                [go scrollViewWillEndDragging:scrollView withVelocity:velocity targetContentOffset:targetContentOffset];
            }
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    
    //propagate event to all delegate listener
    if(_uiscrollViewDelegateListener != nil){
        
        for(id<UIScrollViewDelegate> go in _uiscrollViewDelegateListener){
            
            if([go respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)]){
                
                [go scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
            }
        }
    }
}

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView{
    
    BOOL scrollToTop = YES;
    
    //propagate event to all delegate listener
    if(_uiscrollViewDelegateListener != nil){
        
        for(id<UIScrollViewDelegate> go in _uiscrollViewDelegateListener){
            
            if([go respondsToSelector:@selector(scrollViewShouldScrollToTop:)]){
                
                scrollToTop = scrollToTop && [go scrollViewShouldScrollToTop:scrollView];
            }
        }
    }
    
    return scrollToTop;
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView{
    
    
    //propagate event to all delegate listener
    if(_uiscrollViewDelegateListener != nil){
        
        for(id<UIScrollViewDelegate> go in _uiscrollViewDelegateListener){
            
            if([go respondsToSelector:@selector(scrollViewDidScrollToTop:)]){
                
                [go scrollViewDidScrollToTop:scrollView];
            }
        }
    }
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView{
    
    
    //propagate event to all delegate listener
    if(_uiscrollViewDelegateListener != nil){
        
        for(id<UIScrollViewDelegate> go in _uiscrollViewDelegateListener){
            
            if([go respondsToSelector:@selector(scrollViewWillBeginDecelerating:)]){
                
                [go scrollViewWillBeginDecelerating:scrollView];
            }
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    
    //propagate event to all delegate listener
    if(_uiscrollViewDelegateListener != nil){
        
        for(id<UIScrollViewDelegate> go in _uiscrollViewDelegateListener){
            
            if([go respondsToSelector:@selector(scrollViewDidEndDecelerating:)]){
                
                [go scrollViewDidEndDecelerating:scrollView];
            }
        }
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    
    
    //propagate event to all delegate listener
    if(_uiscrollViewDelegateListener != nil){
        
        for(id<UIScrollViewDelegate> go in _uiscrollViewDelegateListener){
            
            if([go respondsToSelector:@selector(scrollViewDidEndScrollingAnimation:)]){
                
                [go scrollViewDidEndScrollingAnimation:scrollView];
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
