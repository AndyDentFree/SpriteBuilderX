//
//  CCBPScrollView.h
//  SpriteBuilder
//
//  Created by Viktor on 12/17/13.
//
//

#import "CCScrollView.h"

@interface CCBPScrollView : CCScrollView

@property (nonatomic,assign) BOOL clipContent;
@property (nonatomic,readonly) CGRect clippingRect;

@end
