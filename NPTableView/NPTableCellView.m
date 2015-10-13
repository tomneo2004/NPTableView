//
//  NPTableCellController.m
//  NPTableView
//
//  Created by User on 12/10/15.
//  Copyright © 2015 ArcTech. All rights reserved.
//

#import "NPTableCellView.h"

@interface NPTableCellView ()

@end

@implementation NPTableCellView

- (id)initWithNibName:(NSString *)nibName{
    
    self = [super initWithFrame:CGRectNull];
    
    if(self != nil){
        
        NSArray *nibContents = [[NSBundle mainBundle] loadNibNamed:nibName owner:self options:nil];
        
        if(nibContents == nil || nibContents.count == 0){
            
            NSLog(@"Init class %@ fail, no nib file found in main bundle", NSStringFromClass([self class]));
            
            return nil;
        }
        
        UIView *nibView = [nibContents objectAtIndex:0];
        
        self = (id)nibView;
    }
    
    return self;
}

@end
