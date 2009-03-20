//
//  Page.h
//  PageFlip
//
//  Created by Sean Miceli on 1/25/09.
//  Copyright 2009 CoolThingsMade. All rights reserved.
//

#ifdef TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#else
#import <Cocoa/Cocoa.h>
#endif

#import "PVector.h"

typedef struct {
    unsigned int id;

    PVector p0;
    PVector p;
    PVector v;
    PVector f;
    
    CGFloat mass;

    bool fixed;
} Particle;

typedef struct {
    unsigned int from, to;
    CGFloat k;
    CGFloat restLength;
    CGFloat minLength;
    CGFloat maxLength;
    bool hasConstraint;
    CGFloat damping;
} Spring;

extern const char *kLengthConstraint;
extern const char *kAngleConstraint;

typedef struct {
    int from, to;
    CGFloat minLength;
    CGFloat maxLength;
    CGFloat restLength;
} LengthConstraint;

typedef struct {
    int origin, from, to;
    CGFloat minAngle;
    CGFloat maxAngle;
} AngleConstraint;
    
typedef struct {
    const char *type;
    union {
        LengthConstraint length;
        AngleConstraint angle;
    } u;
} Constraint;

typedef struct {
    PVector dpdt;
    PVector dvdt;
} Derivatives;

@interface Page : NSObject {
    CGSize meshSize;
    
    Particle *particles;
    int particleCount;
    
    Spring *springs;
    int springCount;
    
    Constraint *constraints;
    int constraintCount;
    
    Particle *pullParticle;
    Spring *pullSpring;

    Derivatives *derivatives[5];
    
    // intermediat variables
    Particle *particleCopies[5];
}

@property (nonatomic, assign) Particle *particles;
@property (nonatomic, assign) int particleCount;

-(id)initWithSize:(CGSize)size andMeshSize:(CGSize)meshSize;
-(void)updateForces:(Particle*)p;
-(void)computeDerivatives:(Derivatives*)d withParticles:(Particle*)p;
-(void)updateParticles:(CGFloat)dt;
-(void)updateConstraints;
-(void)pullAtPoint:(PVector)point;

@end
