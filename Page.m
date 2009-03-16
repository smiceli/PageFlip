//
//  Page.m
//  PageFlip
//
//  Created by Sean Miceli on 1/25/09.
//  Copyright 2009 CoolThingsMade. All rights reserved.
//

#import "Page.h"

PVector zero = {0, 0, 0};

NSString *stringFromVector(PVector v) {
    return [NSString stringWithFormat:@"[%lf %lf %lf]", v.x, v.y, v.z];
}

int initSpring(Particle *p, Spring *s, Constraint **c, int from, unsigned int to, CGFloat kCoef, CGFloat damping) {
    PVector r = vsub(p[from].p, p[to].p);
    s->from = from;
    s->to = to;
    s->k = kCoef;
    s->restLength = vlength(r);
    s->minLength = s->restLength*.9;
    s->maxLength = s->restLength * 1.1;
    s->hasConstraint = YES;
    s->damping = damping;
    return 1;
}


@implementation Page

@synthesize particles, particleCount;

-(id)initWithSize:(CGSize)size andMeshSize:(CGSize)theMeshSize {
    if(!(self = [super init])) return nil;
    
    meshSize = theMeshSize;
   
    // one additional for pull particle
    particleCount = meshSize.width*meshSize.height + 1;
    particles = malloc(particleCount*sizeof(*particles));
    if(!particles) return nil;
    memset(particles, 0, particleCount*sizeof(*particles));
    
    for(int i = 0; i < sizeof(particleCopies)/sizeof(*particleCopies); i++) {
        particleCopies[i] = malloc(particleCount*sizeof(*particleCopies[0]));
        if(!particleCopies[i]) return nil;
    }
    
    for(int i = 0; i < sizeof(derivatives)/sizeof(*derivatives); i++)
        derivatives[i] = (Derivatives*)malloc(particleCount*sizeof(*derivatives[i]));
    
    CGFloat cellWidth = size.width/(meshSize.width-1);
    CGFloat cellHeight = size.height/(meshSize.height-1);

    Particle *p = particles;
    int id = 0;
    for(int y = 0; y < meshSize.height; y++) {
        for(int x = 0; x < meshSize.width; x++) {
            p->id = id++;
            p->p.x = x*cellWidth;
            p->p.y = y*cellHeight;
            p->p0 = p->p;
            p->mass = 1.0;
            if(x == 0) p->fixed = YES;
            p++;
        }
    }
    
    // aditional one for the pull particle
    springCount = particleCount*8+6+1;
    springs = (Spring*)malloc(springCount*sizeof(*springs));
    memset(springs, 0, springCount*sizeof(*springs));
    
    constraintCount = springCount;
    constraints = (Constraint*)malloc(constraintCount*sizeof(*constraints));
    memset(constraints, 0, constraintCount*sizeof(*constraints));

    CGFloat kd = 2;
    CGFloat ks = 10;

    Spring *s = springs;
    Constraint *c = constraints;
    for(int y = 0; y < meshSize.height; y++) {
        for(int x = 0; x < meshSize.width; x++) {
            unsigned int from = y*meshSize.width+x;
            unsigned int to = from+1;
            if(x+1 < meshSize.width && from >= 0 && to >= 0 && from < particleCount && to < particleCount)
                s += initSpring(particles, s, &c, from, to, ks, kd);
            to = from+meshSize.width;
            if(y+1 < meshSize.height && from >= 0 && to >= 0 && from < particleCount && to < particleCount)
                s += initSpring(particles, s, &c, from, to, ks, kd);
            to = from-meshSize.width+1;
            if(x+1 < meshSize.width && y-1 > 0 && from >= 0 && to >= 0 && from < particleCount && to < particleCount)
                s += initSpring(particles, s, &c, from, to, ks, kd);
            to = from+meshSize.width+1;
            if(x+1 < meshSize.width && y+1 < meshSize.height && from >= 0 && to >= 0 && from < particleCount && to < particleCount)
                s += initSpring(particles, s, &c, from, to, ks, kd);
            to = from+4;
            if(x+4 < meshSize.width && from >= 0 && to >= 0 && from < particleCount && to < particleCount)
                s += initSpring(particles, s, &c, from, to, ks*3, kd);
            to = from+4*meshSize.width;
            if(y+4 < meshSize.height && from >= 0 && to >= 0 && from < particleCount && to < particleCount)
                s += initSpring(particles, s, &c, from, to, ks*3, kd);
        }
    }
    
    int from, to;
//    ks *= 10;
#if 1
//    from = 0;
//    to = from+meshSize.width*(meshSize.height-1);
//    s += initSpring(particles, s, &c, from, to, ks, kd);

    from = meshSize.width-1;
    to = from+meshSize.width*(meshSize.height-1);
    s += initSpring(particles, s, &c, from, to, ks, kd);
#endif
#if 1
    from = 0;
    to = from+meshSize.width-1;
    s += initSpring(particles, s, &c, from, to, ks, kd);
    
    from = meshSize.width*(meshSize.height-1);
    to = from+meshSize.width-1;
    s += initSpring(particles, s, &c, from, to, ks, kd);
#endif
    
#if 1
    from = 0;
    to = from+meshSize.width*(meshSize.height-1)+meshSize.width-1;
    s += initSpring(particles, s, &c, from, to, ks, kd);
    
    from = meshSize.width-1;
    to = meshSize.width*(meshSize.height-1);
    s += initSpring(particles, s, &c, from, to, ks, kd);
#endif

    ks *= 15;
    from = particleCount-1;
    to = (int)(meshSize.width*(meshSize.height)/2+meshSize.width-1);
    pullParticle = &particles[from];
    pullParticle->fixed = YES;
    pullParticle->p = particles[to].p;
    pullParticle->mass = 1.0;
    pullSpring = s;
    initSpring(particles, s, &c, from, to, ks, kd);
    s->hasConstraint = NO;
    s++;

    springCount = s-springs;
    return self;
}

- (void) dealloc
{
    for(int i = 0; i < sizeof(derivatives)/sizeof(*derivatives); i++)
        if(derivatives[i]) free(derivatives[i]);
    
    for(int i = 0; i < sizeof(particleCopies)/sizeof(*particleCopies); i++)
        if(particleCopies[i]) free(particleCopies[i]);
    
    if(particles) free(particles);
    if(springs) free(springs);
    if(constraints) free(constraints);
    
    [super dealloc];
}

-(void)updateForces:(Particle*)theParticles {
    Particle *p = theParticles;
    for(int i = 0; i < particleCount; i++, p++) {
        p->f = zero;
        if(p->fixed)
            continue;
        
        // update global forces gravity, fluid
    }

    p = theParticles;
    Spring *s = springs;
    for(int i = 0; i < springCount; i++) {
        Particle *from = &p[s->from];
        Particle *to = &p[s->to];
        
        PVector dp = vsub(to->p, from->p);
        PVector dv = vsub(to->v, from->v);
        CGFloat length = vlength(dp);

        PVector f;
        f.x = (length-s->restLength) * s->k;
        if(length != 0.0) {
            f.x += s->damping * dv.x*dp.x/length;
            f.x *= -dp.x/length;
        }

        f.y = (length-s->restLength) * s->k;
        if(length != 0.0) {
            f.y += s->damping * dv.y*dp.y/length;
            f.y *= -dp.y/length;
        }

        f.z = (length-s->restLength) * s->k;
        if(length != 0.0) {
            f.z += s->damping * dv.z*dp.z/length;
            f.z *= -dp.z/length;
        }
        
        if(!from->fixed) {
            from->f.x -= f.x;
            from->f.y -= f.y;
            from->f.z -= f.z;
        }
        
        if(!to->fixed) {
            to->f.x += f.x;
            to->f.y += f.y;
            to->f.z += f.z;
        }
        s++;
    }
}

-(void)computeDerivatives:(Derivatives*)d withParticles:(Particle*)p {
    for(int i = 0; i < particleCount; i++) {
        d->dpdt.x = p->v.x;
        d->dpdt.y = p->v.y;
        d->dpdt.z = p->v.z;
        d->dvdt.x = p->f.x/p->mass;
        d->dvdt.y = p->f.y/p->mass;
        d->dvdt.z = p->f.z/p->mass;
        p++;
        d++;
    }
}

-(void)updateParticles:(CGFloat)dt {
#if 0
    [self updateForces:particles];
    [self computeDerivatives:derivatives[0] withParticles:particles];
    
    Particle *p = particles;
    Derivatives *d = derivatives[0];
    for(int i = 0; i < particleCount; i++) {
        p->p.x += d->dpdt.x * dt;
        p->p.y += d->dpdt.y * dt;
        p->p.z += d->dpdt.z * dt;
        p->v.x += d->dvdt.x * dt;
        p->v.y += d->dvdt.y * dt;
        p->v.z += d->dvdt.z * dt;
        if(p->p.z < 0.0) {
            p->p.z = 0.0;
            p->v.z = 0.0;
        }
        p++;
        d++;
    }
#endif
#if 0
    /*
     k1 = h * (*fcn)(y0);
     k2 = h * (*fcn)(y0 + k1 / 2);
     ynew = y0 + k2;
     */
    [self updateForces:particles];
    [self computeDerivatives:derivatives[0] withParticles:particles];
  
    Derivatives *f = derivatives[0];
    Particle *k2 = particleCopies[0];
    Particle *y0 = particles;
    for(int i = 0; i < particleCount; i++) {
        *k2 = *y0;
        k2->p.x += f->dpdt.x * dt/2.0;
        k2->p.y += f->dpdt.y * dt/2.0;
        k2->p.z += f->dpdt.z * dt/2.0;
        k2->v.x += f->dvdt.x * dt/2.0;
        k2->v.y += f->dvdt.y * dt/2.0;
        k2->v.z += f->dvdt.z * dt/2.0;
        y0++;
        k2++;
        f++;
    }
    [self updateForces:particleCopies[0]];
    [self computeDerivatives:derivatives[0] withParticles:particleCopies[0]];
    f = derivatives[0];
    Particle *p = particles;
    for(int i = 0; i < particleCount; i++) {
        p->p.x += f->dpdt.x * dt;
        p->p.y += f->dpdt.y * dt;
        p->p.z += f->dpdt.z * dt;
        p->v.x += f->dvdt.x * dt;
        p->v.y += f->dvdt.y * dt;
        p->v.z += f->dvdt.z * dt;
        if(p->p.z < 0.0) {
            p->p.z = 0.0;
            p->v.z = 0.0;
        }
        p++;
        f++;
    }
#endif
#if 1
    /*
     k1 = h * (*fcn)(y0);
     k2 = h * (*fcn)(y0 + k1/2);
     k3 = h * (*fcn)(y0 + k2/2);
     k4 = h * (*fcn)(y0 + k3);
     ynew = y0 + k1 / 6 + k2 / 3 + k3 / 3 + k4 / 6;
     */
    CGFloat constant[] = {.5, .5, 1};
    Particle *x = particles;
    for(int j = 0; j < 4; j++) {
        Derivatives *k = derivatives[j];
        
        [self updateForces:x];
        [self computeDerivatives:k withParticles:x];
        
        for(int i = 0; i < particleCount; i++) {
            k->dpdt.x *= dt;
            k->dpdt.y *= dt;
            k->dpdt.z *= dt;
            k->dvdt.x *= dt;
            k->dvdt.y *= dt;
            k->dvdt.z *= dt;
            k++;
        }
        
        if(j == 3) break;
        
        Particle *y0 = particles;
        k = derivatives[j];
        x = particleCopies[j];
        CGFloat c = constant[j];
        for(int i = 0; i < particleCount; i++) {
            *x = *y0;
            x->p.x += k->dpdt.x * c;
            x->p.y += k->dpdt.y * c;
            x->p.z += k->dpdt.z * c;
            x->v.x += k->dvdt.x * c;
            x->v.y += k->dvdt.y * c;
            x->v.z += k->dvdt.z * c;
            y0++;
            k++;
            x++;
        }
        x = particleCopies[j];
    }

    Particle *p = particles;
    Derivatives *k1 = derivatives[0];
    Derivatives *k2 = derivatives[1];
    Derivatives *k3 = derivatives[2];
    Derivatives *k4 = derivatives[3];
    for(int i = 0; i < particleCount; i++) {
        p->p.x += k1->dpdt.x/6.0 + k2->dpdt.x/3.0 + k3->dpdt.x/3.0 + k4->dpdt.x/6.0;
        p->p.y += k1->dpdt.y/6.0 + k2->dpdt.y/3.0 + k3->dpdt.y/3.0 + k4->dpdt.y/6.0;
        p->p.z += k1->dpdt.z/6.0 + k2->dpdt.z/3.0 + k3->dpdt.z/3.0 + k4->dpdt.z/6.0;
        p->v.x += k1->dvdt.x/6.0 + k2->dvdt.x/3.0 + k3->dvdt.x/3.0 + k4->dvdt.x/6.0;
        p->v.y += k1->dvdt.y/6.0 + k2->dvdt.y/3.0 + k3->dvdt.y/3.0 + k4->dvdt.y/6.0;
        p->v.z += k1->dvdt.z/6.0 + k2->dvdt.z/3.0 + k3->dvdt.z/3.0 + k4->dvdt.z/6.0;
        if(p->p.z < 0.0) {
            p->p.z = 0.0;
            p->v.z = 0.0;
        }
        p++;
        k1++; k2++; k3++; k4++;
    }
    
#endif
    
    p = particles;
    for(int i = 0; i < 20; i++) {
        bool fixedUp = NO;
        Spring *s = springs;
        for(int si = 0; si < springCount; si++, s++) {
            if(!s->hasConstraint) continue;
            Particle *from = &p[s->from];
            Particle *to = &p[s->to];
            
            PVector v = vsub(to->p, from->p);
            CGFloat len = vlength(v);
            CGFloat linearImpulse;
            bool doConstraint = NO;
            if(len < s->minLength) {
                linearImpulse = len-s->minLength;
                doConstraint = YES;
            }
            else if(len > s->maxLength) {
                linearImpulse = len-s->maxLength;
                doConstraint = YES;
            }
            
            if(doConstraint) {
                PVector normal = vnormalize(v);
                PVector impulse = vmulConst(normal, linearImpulse);
                
                if(!to->fixed) {
                    to->v = vsub(to->v, impulse);
                    to->p = vsub(to->p, impulse);
                    fixedUp = YES;
                }
                if(!from->fixed) {
                    from->v = vadd(from->v, impulse);
                    from->p = vadd(from->p, impulse);
                    fixedUp = YES;
                }
            }
        }
        if(!fixedUp) {
//            NSLog(@"%d\n", i);
            break;
        }
    }
}

-(void)updateConstraints {
    Constraint *c = constraints;
    for(int i = 0; i < constraintCount; i++) {
        Particle *from = &particles[c->from];
        Particle *to = &particles[c->from];
        CGFloat d = vlength(vsub(from->p0, to->p0));
        c->c = abs(d-c->restLength)-.1*c->restLength;
        if(c->c < 0) c->c = 0;
    }
}

-(void)pullAtPoint:(PVector)point {
    pullParticle->p.x = point.x;
    pullParticle->p.y = point.y;
    pullParticle->p.z = point.z;

    Particle *p = particles + (int)meshSize.width-1;
    int yi;
    for(yi = 0; yi < (int)meshSize.height; yi++) {
        if(point.y < p->p.y)
            break;
        p += (int)meshSize.width;
    }
    pullSpring->to = p->id;
}

@end
