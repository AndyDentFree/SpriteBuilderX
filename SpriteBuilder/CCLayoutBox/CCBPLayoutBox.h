//
//  CCBPLayoutBox.h
//  SpriteBuilder
//
//  Created by Viktor on 12/17/13.
//
//

#import "CCLayoutBox.h"

@interface CCBPLayoutBox : CCLayoutBox

@property (nonatomic,assign) BOOL clipContent;
@property (nonatomic,readonly) CGRect clippingRect;

@end
