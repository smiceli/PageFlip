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
    PVector a;
    PVector f;
    
    double mass;

    bool fixed;
} Particle;

typedef struct {
    unsigned int from, to;
    double k;
    double restLength;
    double damping;
    bool constrainLength;
} Spring;

typedef struct {
    int from, to;
    double c;
    double dc;
    double j;
    double dj;
    double minDistance;
    double maxDistance;
    double restLength;
} Constraint;

typedef struct {
    PVector dpdt;
    PVector dvdt;
} Derivatives;

@interface Page : NSObject {
    Particle *particles;
    int particleCount;
    
    Spring *springs;
    int springCount;
    
    Constraint *constraints;
    int constraintCount;
    
    Particle *pullParticle;

    Derivatives *derivatives[5];
    
    // intermediat variables
    Particle *particleCopies[5];
}

@property (nonatomic, assign) Particle *particles;
@property (nonatomic, assign) int particleCount;

-(id)initWithSize:(CGSize)size andMeshSize:(CGSize)meshSize;
-(void)updateForces:(Particle*)p;
-(void)computeDerivatives:(Derivatives*)d withParticles:(Particle*)p;
-(void)updateParticles:(double)dt;
-(void)updateConstraints;
-(void)pullAtPoint:(PVector)point;

@end
