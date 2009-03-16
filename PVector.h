//
//  PVector.h
//  PageFlip
//
//  Created by Sean Miceli on 2/4/09.
//  Copyright 2009 CoolThingsMade. All rights reserved.
//

typedef struct {
    CGFloat x, y, z;
} PVector;

__inline__ PVector vsub(PVector a, PVector b) __attribute__((always_inline));
__inline__ PVector vsub(PVector a, PVector b) {
    PVector c;
    c.x = a.x-b.x;
    c.y = a.y-b.y;
    c.z = a.z-b.z;
    return c;
}

__inline__ PVector vadd(PVector a, PVector b) __attribute__((always_inline));
__inline__ PVector vadd(PVector a, PVector b) {
    PVector c;
    c.x = a.x+b.x;
    c.y = a.y+b.y;
    c.z = a.z+b.z;
    return c;
}

__inline__ PVector vmul(PVector a, PVector b) __attribute__((always_inline));
__inline__ PVector vmul(PVector a, PVector b) {
    PVector c;
    c.x = a.x*b.x;
    c.y = a.y*b.y;
    c.z = a.z*b.z;
    return c;
}

__inline__ PVector vmulConst(PVector a, CGFloat k) __attribute__((always_inline));
__inline__ PVector vmulConst(PVector a, CGFloat k) {
    PVector c;
    c.x = a.x*k;
    c.y = a.y*k;
    c.z = a.z*k;
    return c;
}

__inline__ CGFloat vlength(PVector v) __attribute__((always_inline));
__inline__ CGFloat vlength(PVector v) {
    return sqrt(v.x*v.x+v.y*v.y+v.z*v.z);
}

__inline__ PVector vnormalize(PVector v) __attribute__((always_inline));
__inline__ PVector vnormalize(PVector v) {
    CGFloat length = vlength(v);
    PVector c;
    c.x = v.x/length;
    c.y = v.y/length;
    c.z = v.z/length;
    return c;
}

__inline__ PVector crossProduct(PVector a, PVector b) __attribute__((always_inline));
__inline__ PVector crossProduct(PVector a, PVector b) {
    PVector c;
    c.x = a.y*b.z-a.z*b.y;
    c.y = a.z*b.x-a.x*b.z;
    c.z = a.x*b.y-a.y*b.x;
    return c;
}

__inline__ PVector normal3(PVector a, PVector b, PVector o) __attribute__ ((always_inline));
__inline__ PVector normal3(PVector a, PVector b, PVector o) {
    a = vsub(a, o);
    b = vsub(b, o);
    return vnormalize(crossProduct(a, b));
}


