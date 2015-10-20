//
//  PullDownAddNew.m
//  NPTableView
//
//  Created by User on 16/10/15.
//  Copyright © 2015 ArcTech. All rights reserved.
//

#import "PullDownAddNew.h"



@implementation PullDownAddNew{
    
    PDANCellHolder *_cellHolder;
    UIView *_maskView;
    BOOL _pullDownInProgress;
    BOOL _onEdit;
}

- (id)initWithTableView:(NPTableView *)tableView WithPriority:(NSInteger)priority{
    
    if(self = [super initWithTableView:tableView WithPriority:priority]){
        
        
        _cellHolder = [PDANCellHolder CellHolderWithNibName:@"PDANCellHolder"];
        _maskView = [[UIView alloc] initWithFrame:CGRectNull];
        _maskView.backgroundColor = [UIColor colorWithRed:0.1f green:0.1f blue:0.1f alpha:0.5f];
        _cellHolder.delegate = self;
    }
    
    return self;
}

/*
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    
    _pullDownInProgress = scrollView.contentOffset.y <= 0.0f;
    
    if(_pullDownInProgress){

        _cellHolder.frame = CGRectMake(0, 0, _tableView.scrollView.bounds.size.width, _cellHolder.bounds.size.height);
        [_tableView insertSubview:_cellHolder atIndex:1];
    }
}
 */

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    if(_onEdit)
        return;
    
    _pullDownInProgress = scrollView.contentOffset.y < 0.0f;
    
    if(_pullDownInProgress && _cellHolder.superview == nil){
        
        _cellHolder.frame = CGRectMake(0, 0, _tableView.scrollView.bounds.size.width, _cellHolder.bounds.size.height);
        [_tableView insertSubview:_cellHolder atIndex:1];
    }
    
    if(_pullDownInProgress && _tableView.scrollView.contentOffset.y <= 0.0f){
        
        CGFloat cellHolderY = MIN(0.0f, (-_tableView.scrollView.contentOffset.y) - _tableView.defatultRowHeight);
        _cellHolder.frame = CGRectMake(0, cellHolderY, _cellHolder.bounds.size.width, _cellHolder.bounds.size.height);
        
        [_cellHolder changeItemText:-_tableView.scrollView.contentOffset.y > _tableView.defatultRowHeight ? @"Release to Add Item" : @"Pull to Add Item"];
        
        _cellHolder.alpha = MIN(1.0f, -_tableView.scrollView.contentOffset.y / _tableView.defatultRowHeight);
    }
    else{
        
        _pullDownInProgress = NO;
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    
    if(_pullDownInProgress && -_tableView.scrollView.contentOffset.y > _tableView.defatultRowHeight){
        
        _onEdit = YES;
        
        _tableView.interactionEnable = NO;
        
        _cellHolder.frame = CGRectMake(0, 0, _tableView.scrollView.bounds.size.width, _cellHolder.bounds.size.height);
        
        _maskView.frame = CGRectMake(0, 0, _tableView.bounds.size.width, _tableView.bounds.size.height);
        
        [_tableView insertSubview:_maskView atIndex:1];
        [_tableView bringSubviewToFront:_cellHolder];
        [_cellHolder startEdit];
    }
    else{
        
        [_cellHolder removeFromSuperview];
    }
    
    _pullDownInProgress = NO;
}

#pragma mark - PDANCellHolder delegate
- (void)endEditWithText:(NSString *)text{
    
    _onEdit = NO;
    
    _tableView.interactionEnable = YES;
    
    [_maskView removeFromSuperview];
    [_cellHolder removeFromSuperview];
    
    if([text length] <= 0)
        return;
    
    if([self.delegate respondsToSelector:@selector(addNewItemWithText:)]){
        
        [self.delegate addNewItemWithText:text];
    }
}

@end
