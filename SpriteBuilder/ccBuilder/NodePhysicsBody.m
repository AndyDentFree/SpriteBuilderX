/*
 * CocosBuilder: http://www.cocosbuilder.com
 *
 * Copyright (c) 2013 Apportable Inc
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#import "NodePhysicsBody.h"
#import "AppDelegate.h"
#import "PolyDecomposition.h"

#define kCCBPhysicsMinimumDefaultCircleRadius 16

@implementation NodePhysicsBody

- (id) initWithNode:(CCNode*) node
{
    self = [super init];
    if (!self) return NULL;
    
    [self setupDefaultPolygonForNode:node];
    
    _dynamic = (node.hasKeyframes) ? NO : YES;
    _affectedByGravity = YES;
    _allowsRotation = YES;
    
    _density = 1.0f;
    _friction = 0.3f;
    _elasticity = 0.3f;
    
    _categoryBitmask = 0xFFFFFFFF;
    _contactTestBitmask = 0;
    _collisionBitmask = 0xFFFFFFFF;
    
    _massSet = NO;
    _momentSet = NO;
    
    return self;
}

- (id) initWithSerialization:(id)ser
{
    self = [super init];
    if (!self) return NULL;
    
    // Shape
    _bodyShape = [[ser objectForKey:@"bodyShape"] intValue];
    _cornerRadius = [[ser objectForKey:@"cornerRadius"] floatValue];
    
    // Points
    NSArray* serPoints = [ser objectForKey:@"points"];
    NSMutableArray* points = [NSMutableArray array];
    for (NSArray* serPt in serPoints)
    {
        CGPoint pt = CGPointZero;
        pt.x = [[serPt objectAtIndex:0] floatValue];
        pt.y = [[serPt objectAtIndex:1] floatValue];
        [points addObject:[NSValue valueWithPoint:pt]];
    }
    
    self.points = points;
    
    // Basic physics props
    _dynamic = [[ser objectForKey:@"dynamic"] boolValue];
    _affectedByGravity = [[ser objectForKey:@"affectedByGravity"] boolValue];
    _allowsRotation = [[ser objectForKey:@"allowsRotation"] boolValue];
    
    _density = [[ser objectForKey:@"density"] floatValue];
    _friction = [[ser objectForKey:@"friction"] floatValue];
    _elasticity = [[ser objectForKey:@"elasticity"] floatValue];
    
    _mass = [[ser objectForKey:@"mass"] floatValue];
    _moment = [[ser objectForKey:@"moment"] floatValue];
    _massSet = [[ser objectForKey:@"massSet"] boolValue];
    _momentSet = [[ser objectForKey:@"momentSet"] boolValue];
    
    _scaleByResourceScale = [[ser objectForKey:@"scaleByResourceScale"] boolValue];
    
    _categoryBitmask  = (unsigned int)[[ser objectForKey:@"categoryBitmask"] integerValue];
    _contactTestBitmask = (unsigned int)[[ser objectForKey:@"contactTestBitmask"] integerValue];
    _collisionBitmask = (unsigned int)[[ser objectForKey:@"collisionBitmask"] integerValue];
    
    _velocityX = [[ser objectForKey:@"velocityX"] floatValue];
    _velocityY = [[ser objectForKey:@"velocityY"] floatValue];
    _velocityLimit = [[ser objectForKey:@"velocityLimit"] floatValue];
    _angleVelocity = [[ser objectForKey:@"angleVelocity"] floatValue];
    _angleVelocityLimit = [[ser objectForKey:@"angleVelocityLimit"] floatValue];
    _linearDamping = [[ser objectForKey:@"linearDamping"] floatValue];
    _angularDamping = [[ser objectForKey:@"angularDamping"] floatValue];
    
    return self;
}

- (id) serialization
{
    NSMutableDictionary* ser = [NSMutableDictionary dictionary];
    
    // Shape
    [ser setObject:[NSNumber numberWithInt:_bodyShape] forKey:@"bodyShape"];
    [ser setObject:[NSNumber numberWithFloat:_cornerRadius] forKey:@"cornerRadius"];
    
    // Points
    NSMutableArray* serPoints = [NSMutableArray array];
    for (NSValue* val in _points)
    {
        CGPoint pt = [val pointValue];
        NSArray* serPt = [NSArray arrayWithObjects:
                       [NSNumber numberWithFloat:pt.x],
                       [NSNumber numberWithFloat:pt.y],
                       nil];
        [serPoints addObject:serPt];
    }
    [ser setObject:serPoints forKey:@"points"];
    
    //Polygons
    NSMutableArray * serPolygons = [NSMutableArray array];
    for (NSArray * polygon in _polygons) {
        
        NSMutableArray * serPolygon = [NSMutableArray array];
        for (NSValue* val in polygon)
        {
            CGPoint pt = [val pointValue];
            NSArray* serPt = [NSArray arrayWithObjects:
                              [NSNumber numberWithFloat:pt.x],
                              [NSNumber numberWithFloat:pt.y],
                              nil];
            [serPolygon addObject:serPt];
        }
        [serPolygons addObject:serPolygon];
    }
    [ser setObject:serPolygons forKey:@"polygons"];
    
    // Basic physics props
    [ser setObject:[NSNumber numberWithBool:_dynamic] forKey:@"dynamic"];
    [ser setObject:[NSNumber numberWithBool:_affectedByGravity] forKey:@"affectedByGravity"];
    [ser setObject:[NSNumber numberWithBool:_allowsRotation] forKey:@"allowsRotation"];
    
    [ser setObject:[NSNumber numberWithFloat:_density] forKey:@"density"];
    [ser setObject:[NSNumber numberWithFloat:_friction] forKey:@"friction"];
    [ser setObject:[NSNumber numberWithFloat:_elasticity] forKey:@"elasticity"];
    
    [ser setObject:[NSNumber numberWithFloat:_mass] forKey:@"mass"];
    [ser setObject:[NSNumber numberWithFloat:_moment] forKey:@"moment"];
    [ser setObject:[NSNumber numberWithBool:_massSet] forKey:@"_massSet"];
    [ser setObject:[NSNumber numberWithBool:_momentSet] forKey:@"_momentSet"];
    
    [ser setObject:[NSNumber numberWithBool:_scaleByResourceScale] forKey:@"scaleByResourceScale"];
    
    [ser setObject:[NSNumber numberWithUnsignedInt:_categoryBitmask] forKey:@"categoryBitmask"];
    [ser setObject:[NSNumber numberWithUnsignedInt:_contactTestBitmask] forKey:@"contactTestBitmask"];
    [ser setObject:[NSNumber numberWithUnsignedInt:_collisionBitmask] forKey:@"collisionBitmask"];
    
    [ser setObject:[NSNumber numberWithBool:_velocityX] forKey:@"velocityX"];
    [ser setObject:[NSNumber numberWithBool:_velocityY] forKey:@"velocityY"];
    [ser setObject:[NSNumber numberWithBool:_velocityLimit] forKey:@"velocityLimit"];
    [ser setObject:[NSNumber numberWithBool:_angleVelocity] forKey:@"angleVelocity"];
    [ser setObject:[NSNumber numberWithBool:_angleVelocityLimit] forKey:@"angleVelocityLimit"];
    [ser setObject:[NSNumber numberWithBool:_linearDamping] forKey:@"linearDamping"];
    [ser setObject:[NSNumber numberWithBool:_angularDamping] forKey:@"angularDamping"];
    
    return ser;
}

- (void) setupDefaultPolygonForNode:(CCNode*) node
{
    _bodyShape = kCCBPhysicsBodyShapePolygon;
    self.cornerRadius = 0;
    
    float w = node.contentSize.width;
    float h = node.contentSize.height;
    //CGPoint anchorPoint = node.anchorPoint;
    
    
    if (w == 0)
    {
        w = 32;
    }
    if (h == 0)
    {
        h = 32;
    }
    
    // Calculate corners
    CGPoint a = ccp(0, 0);
    CGPoint b = ccp(0, h);
    CGPoint c = ccp(w, h);
    CGPoint d = ccp(w, 0);
    
    self.points = [NSArray arrayWithObjects:
                   [NSValue valueWithPoint:a],
                   [NSValue valueWithPoint:b],
                   [NSValue valueWithPoint:c],
                   [NSValue valueWithPoint:d],
                   nil];
}

- (void) setupDefaultCircleForNode:(CCNode*) node
{
    _bodyShape = kCCBPhysicsBodyShapeCircle;
    
    float radius = MAX(node.contentSize.width/2, node.contentSize.height/2);
    if (radius < kCCBPhysicsMinimumDefaultCircleRadius) radius = kCCBPhysicsMinimumDefaultCircleRadius;
    
    self.cornerRadius = radius;
    
    float w = node.contentSize.width;
    float h = node.contentSize.height;
    
    self.points = [NSArray arrayWithObject:[NSValue valueWithPoint:ccp(w/2, h/2)]];
}

- (void) setBodyShape:(CCBPhysicsBodyShape)bodyShape
{
    if (bodyShape == _bodyShape) return;
    
    [[AppDelegate appDelegate] saveUndoStateWillChangeProperty:@"*P*bodyShape"];
    _bodyShape = bodyShape;
    
    if (bodyShape == kCCBPhysicsBodyShapePolygon)
    {
        [self setupDefaultPolygonForNode:[AppDelegate appDelegate].selectedNode];
    }
    else if (bodyShape == kCCBPhysicsBodyShapeCircle)
    {
        [self setupDefaultCircleForNode:[AppDelegate appDelegate].selectedNode];
    }
}

- (void) setCornerRadius:(float)cornerRadius
{
    [[AppDelegate appDelegate] saveUndoStateWillChangeProperty:@"*P*cornerRadius"];
    _cornerRadius = cornerRadius;
}

- (void) setPoints:(NSArray *)points
{
    if (points == _points) return;
    _points = points;
    
    if(points && _bodyShape == kCCBPhysicsBodyShapePolygon)
    {
        NSArray * outputPolygons;
        if(![PolyDecomposition bayazitDecomposition:points outputPoly:&outputPolygons])
        {
            self.polygons = @[[PolyDecomposition makeConvexHull:points]];
        }
        else
        {
            self.polygons = outputPolygons;
        }
    }
    else
    {
        self.polygons = nil;
    }
    
}

- (void) setDynamic:(BOOL)dynamic
{
    [[AppDelegate appDelegate] saveUndoStateWillChangeProperty:@"*P*dynamic"];
    _dynamic = dynamic;
}

- (void) setAffectedByGravity:(BOOL)affectedByGravity
{
    [[AppDelegate appDelegate] saveUndoStateWillChangeProperty:@"*P*affectedByGravity"];
    _affectedByGravity = affectedByGravity;
}

- (void) setAllowsRotation:(BOOL)allowsRotation
{
    [[AppDelegate appDelegate] saveUndoStateWillChangeProperty:@"*P*allowsRotation"];
    _allowsRotation = allowsRotation;
}

- (void) setDensity:(float)density
{
    [[AppDelegate appDelegate] saveUndoStateWillChangeProperty:@"*P*density"];
    _density = density;
}

- (void) setFriction:(float)friction
{
    [[AppDelegate appDelegate] saveUndoStateWillChangeProperty:@"*P*friction"];
    _friction = friction;
}

- (void) setElasticity:(float)elasticity
{
    [[AppDelegate appDelegate] saveUndoStateWillChangeProperty:@"*P*elasticity"];
    _elasticity = elasticity;
}

- (void) dealloc
{

}

@end
