//
//  HISCollectionViewLayout.m
//  Bind
//
//  Created by Tim Hise on 2/14/14.
//  Copyright (c) 2014 CleverKnot. All rights reserved.
//

#import "HISCollectionViewLayout.h"
static CGFloat kItemSize = 100.0f;
#define attachmentPoint CGPointMake(CGRectGetMidX(self.collectionView.bounds), 64)

@interface HISCollectionViewLayout ()

@property (strong, nonatomic) UIDynamicAnimator *dynamicAnimator;
@property (nonatomic, weak) UIGravityBehavior *gravityBehaviour;
@property (nonatomic, weak) UICollisionBehavior *collisionBehaviour;

@end

@implementation HISCollectionViewLayout


-(id)init {
    if (!(self = [super init])) return nil;
    
    self.dynamicAnimator = [[UIDynamicAnimator alloc] initWithCollectionViewLayout:self];
    
    UIGravityBehavior *gravityBehaviour = [[UIGravityBehavior alloc] initWithItems:@[]];
    gravityBehaviour.gravityDirection = CGVectorMake(0, 1);
    self.gravityBehaviour = gravityBehaviour;
    [self.dynamicAnimator addBehavior:gravityBehaviour];
    
    UICollisionBehavior *collisionBehaviour = [[UICollisionBehavior alloc] initWithItems:@[]];
    [self.dynamicAnimator addBehavior:collisionBehaviour];
    self.collisionBehaviour = collisionBehaviour;
    
    return self;
}


-(CGSize)collectionViewContentSize
{
    return self.collectionView.bounds.size;
}

-(void)prepareForCollectionViewUpdates:(NSArray *)updateItems
{
    [super prepareForCollectionViewUpdates:updateItems];
    
    [updateItems enumerateObjectsUsingBlock:^(UICollectionViewUpdateItem *updateItem, NSUInteger idx, BOOL *stop) {
        if (updateItem.updateAction == UICollectionUpdateActionInsert)
        {
            UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:updateItem.indexPathAfterUpdate];
            
            attributes.frame = CGRectMake(CGRectGetMaxX(self.collectionView.frame) + kItemSize, 300, kItemSize, kItemSize);
            
            UIAttachmentBehavior *attachmentBehaviour = [[UIAttachmentBehavior alloc] initWithItem:attributes attachedToAnchor:attachmentPoint];
            attachmentBehaviour.length = 300.0f;
            attachmentBehaviour.damping = 0.4f;
//            attachmentBehaviour.frequency = 1.0f;
            [self.dynamicAnimator addBehavior:attachmentBehaviour];
            
            [self.gravityBehaviour addItem:attributes];
            [self.collisionBehaviour addItem:attributes];
        }
    }];
}

-(UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self.dynamicAnimator layoutAttributesForCellAtIndexPath:indexPath];
}

-(NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    return [self.dynamicAnimator itemsInRect:rect];
}

#pragma mark - Public methods
-(void)detachItemAtIndexPath:(NSIndexPath *)indexPath completion:(void (^)(void))completion {
    __block UIAttachmentBehavior *attachmentBehaviour;
    __block UICollectionViewLayoutAttributes *attributes;
    
    [self.dynamicAnimator.behaviors enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[UIAttachmentBehavior class]]) {
            if ([[[obj items].firstObject indexPath] isEqual:indexPath]) {
                attachmentBehaviour = obj;
                attributes = [[obj items] firstObject];
                *stop = YES;
            }
        }
    }];
    
    [self.dynamicAnimator removeBehavior:attachmentBehaviour];
    
    double delayInSeconds = 2;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self.collisionBehaviour removeItem:attributes];
        [self.gravityBehaviour removeItem:attributes];
        
        [self.collectionView performBatchUpdates:^{
            completion();
            [self.collectionView deleteItemsAtIndexPaths:@[indexPath]];
        } completion:nil];
    });
}



@end
