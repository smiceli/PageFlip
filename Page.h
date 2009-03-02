//
//  Page.h
//  PageFlip
//
//  Created by Sean Miceli on 1/25/09.
//  Copyright 2009 CoolThingsMade. All rights reserved.
//

#import <Cocoa/Cocoa.h>
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
    double minLength;
    double maxLength;
    double damping;
} Spring;

typedef struct {
    PVector dpdt;
    PVector dvdt;
} Derivatives;

@interface Page : NSObject {
    Particle *particles;
    int particleCount;
    
    Spring *springs;
    int springCount;
    
    Particle *pullParticle;

    Derivatives *derivatives[5];
    
    // intermediat variables
    Particle *particleCopies[5];
}

@property (nonatomic, assign) Particle *particles;
@property (nonatomic, assign) int particleCount;

-(id)initWithSize:(NSSize)size andMeshSize:(NSSize)meshSize;
-(void)updateForces:(Particle*)p;
-(void)computeDerivatives:(Derivatives*)d withParticles:(Particle*)p;
-(void)updateParticles:(double)dt;
-(void)pullAtPoint:(PVector)point;

@end
