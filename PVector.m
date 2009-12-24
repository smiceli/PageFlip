//
//  PVector.m
//  PageFlip
//
//  Created by Sean Miceli on 2/4/09.
//  Copyright 2009 CoolThingsMade. All rights reserved.
//

#import "PVector.h"

// ax + by + cz + d = 0
// a, b, c, & d stored in planeEq
void planeEquation(CGFloat planeEq[4], PVector a, PVector b, PVector o) {
    PVector planeNormal = normal3(a, b, o);
    planeEq[0] = planeNormal.x;
    planeEq[1] = planeNormal.y;
    planeEq[2] = planeNormal.z;
    planeEq[3] = -(planeEq[0]*o.x + planeEq[1]*o.y + planeEq[2]*o.z);
}

void fillInPlanarShadowMatrix(CGFloat projMatrix[16], CGFloat planeEq[4], PVector lightPos)
{
	CGFloat a = planeEq[0];
	CGFloat b = planeEq[1];
	CGFloat c = planeEq[2];
	CGFloat d = planeEq[3];
    
	CGFloat dx = -lightPos.x;
	CGFloat dy = -lightPos.y;
	CGFloat dz = -lightPos.z;
    
	projMatrix[0] = b * dy + c * dz;
	projMatrix[1] = -a * dy;
	projMatrix[2] = -a * dz;
	projMatrix[3] = (CGFloat)0.0;
    
	projMatrix[4] = -b * dx;
	projMatrix[5] = a * dx + c * dz;
	projMatrix[6] = -b * dz;
	projMatrix[7] = (CGFloat)0.0;
    
	projMatrix[8] = -c * dx;
	projMatrix[9] = -c * dy;
	projMatrix[10] = a * dx + b * dy;
	projMatrix[11] = (CGFloat)0.0;
    
	projMatrix[12] = -d * dx;
	projMatrix[13] = -d * dy;
	projMatrix[14] = -d * dz;
	projMatrix[15] = a * dx + b * dy + c * dz;
}
