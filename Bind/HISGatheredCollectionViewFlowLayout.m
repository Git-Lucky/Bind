//
//  HISGatheredCollectionViewFlowLayout.m
//  Bind
//
//  Created by Tim Hise on 2/13/14.
//  Copyright (c) 2014 CleverKnot. All rights reserved.
//

#import "HISGatheredCollectionViewFlowLayout.h"
#import "HISCollectionViewDataSource.h"
#import "HISBuddy.h"

@interface HISGatheredCollectionViewFlowLayout ()

@property (strong, nonatomic) UIDynamicAnimator *dynamicAnimator;
@property (strong, nonatomic) NSMutableArray *layoutAttributes;


@end

@implementation HISGatheredCollectionViewFlowLayout

- (id)init
{
    if (!(self = [super init])) return nil;
    
    self.minimumInteritemSpacing = 10;
    self.minimumLineSpacing = 10;
    self.itemSize = CGSizeMake(44, 44);
    self.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
    
    self.dynamicAnimator = [[UIDynamicAnimator alloc] initWithCollectionViewLayout:self];
    
    return self;
}

- (NSMutableArray *)layoutAttributes
{
    if (!_layoutAttributes){
        _layoutAttributes = [[NSMutableArray alloc] init];
    }
    
    return _layoutAttributes;
}

-(void)prepareLayout
{
    [super prepareLayout];
    
    CGSize contentSize = self.collectionView.contentSize;
    NSArray *items = [super layoutAttributesForElementsInRect:CGRectMake(0, 0, contentSize.width, contentSize.height)];
    
    if (self.dynamicAnimator.behaviors.count == 0) {
        [items enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            UIAttachmentBehavior *behaviour = [[UIAttachmentBehavior alloc] initWithItem:obj attachedToAnchor:[obj center]];
            
            behaviour.length = 0.0f;
            behaviour.damping = 0.8f;
            behaviour.frequency = 1.0f;
            
            [self.dynamicAnimator addBehavior:behaviour];
        }];
    }
}


- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    return [self.dynamicAnimator itemsInRect:rect];
    /*
    HISCollectionViewDataSource *dataSource = self.collectionView.dataSource;
    NSArray *indexPaths = [dataSource indexPathsOfBuddies];
    for (NSIndexPath *indexPath in indexPaths)
    {
        HISLayoutAttributes *attributes = [self layoutAttributesForItemAtIndexPath:indexPath];
        [self.layoutAttributes addObject:attributes];
    }
    return self.layoutAttributes;
     */
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.dynamicAnimator layoutAttributesForCellAtIndexPath:indexPath];
}

//- (HISLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
//{
////    CalendarDataSource *dataSource = self.collectionView.dataSource;
////    id<CalendarEvent> event = [dataSource eventAtIndexPath:indexPath];
////    UICollectionViewLayoutAttributes *attributes =
////    [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
////    attributes.frame = [self frameForEvent:event];
////    return attributes;
//    
//    //HISCollectionViewDataSource *dataSource = self.collectionView.dataSource;
//    //HISBuddy *buddy = dataSource.buddies[indexPath.row];
//    HISLayoutAttributes *attributes = [HISLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
//    attributes.center = CGPointMake(50*(indexPath.row + 1), 100);
//    attributes.size = CGSizeMake(60, 60);
//    attributes.backgroundImage.image = [UIImage imageNamed:@"placeholder.jpg"];
//    return attributes;
//}


- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
//    UIScrollView *scrollView = self.collectionView;
//    
//    CGFloat delta = newBounds.origin.y - scrollView.bounds.origin.y;
//    CGPoint touchLocation = [self.collectionView.panGestureRecognizer locationInView:self.collectionView];
//    [self.dynamicAnimator.behaviors enumerateObjectsUsingBlock:^(UIAttachmentBehavior *springBehavior, NSUInteger idx, BOOL *stop) {
//        CGFloat yDistanceFromTouch = fabsf(touchLocation.y - springBehavior.anchorPoint.y);
//        CGFloat xDistanceFromTouch = fabsf(touchLocation.x - springBehavior.anchorPoint.x);
//        CGFloat scrollResistance = (yDistanceFromTouch + xDistanceFromTouch)/ 1500.0f;
//        
//        UICollectionViewLayoutAttributes *item = springBehavior.items.firstObject;
//        CGPoint center = item.center;
//        
//        if (delta < 0) {
//            center.y += MAX(delta, delta * scrollResistance);
//        } else {
//            center.y += MIN(delta, delta * scrollResistance);
//        }
//        item.center = center;
//        
//        [self.dynamicAnimator updateItemUsingCurrentState:item];
//    }];
//
//    return NO;
    return YES;
}




@end
