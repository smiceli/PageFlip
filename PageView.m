//
//  PageView.m
//  PageFlip
//
//  Created by Sean Miceli on 1/25/09.
//  Copyright 2009 CoolThingsMade. All rights reserved.
//

#import "PageView.h"
#import "NSBitmapImageRep+Texturing.h"

typedef struct {
    double r, g, b;
} BlockColor;

BlockColor *blockColors;

@implementation PageView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (void) dealloc {
    [super dealloc];
}


-(void)prepareOpenGL {
    meshSize = NSMakeSize(31, 31);
    blockColors = (BlockColor*)malloc(meshSize.width*meshSize.height*sizeof(*blockColors));
    for(int i = 0; i < meshSize.width*meshSize.height; i++) {
#if 0
        blockColors[i].r = 1.0;
        blockColors[i].g = 0;
        blockColors[i].b = 0;
#else
        blockColors[i].r = rand()/(float)RAND_MAX;
        blockColors[i].g = rand()/(float)RAND_MAX;
        blockColors[i].b = rand()/(float)RAND_MAX;
#endif
    }
    [super prepareOpenGL];
    [[self window] setAcceptsMouseMovedEvents:YES];
    [[self window] makeFirstResponder:self];
    [self setBounds:NSMakeRect(-1, -1, 2, 2)];
    page = [[Page alloc] initWithSize:NSMakeSize(1.0, 1.0) andMeshSize:meshSize];    

//    mouseParticle = &[page particles][(int)(meshSize.width*(meshSize.height-1)/2+meshSize.width-1)];
//    mouseParticle2 = mouseParticle + (int)meshSize.width;

    NSImage *image = [NSImage imageNamed:@"ethan.jpg"];
    if(!image) return;
    
    
    NSImageRep *imageRep = [image bestRepresentationForDevice:nil];
    if(![imageRep isKindOfClass:[NSBitmapImageRep class]]) return;
  
#if 0
    NSBitmapImageRep *bitmapImageRep = (NSBitmapImageRep*)imageRep;
    glGenTextures(1, &imageTexture);
    [bitmapImageRep copyToGLTexture:imageTexture];
#endif
    
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    glFrustum(-1.0, 1.0, -1.0, 1.0, 1, 6);
    glMatrixMode(GL_MODELVIEW);
    
    glTranslated(0, 0, -2);

    glEnable(GL_LIGHTING);
    
    GLfloat global_ambient[] = { .4, .4, .4, .4 };
    glLightModelfv(GL_LIGHT_MODEL_AMBIENT, global_ambient);

    GLfloat ambient[] = { .3, .3,.3 };
    glLightfv(GL_LIGHT0, GL_AMBIENT, ambient);
    GLfloat diffuseLight[] = { 0.9f, 0.9f, 0.9, 1.0f };
    glLightfv(GL_LIGHT0, GL_DIFFUSE, diffuseLight);
//    GLfloat specularLight[] = { 0.4f, 0.4f, 0.4, 1.0f };
//    glLightfv(GL_LIGHT0, GL_SPECULAR, specularLight);
    PVector vposition = { -1.5, 1.5, 1.5};
    GLfloat position[4];
    position[0] = vposition.x;
    position[1] = vposition.y;
    position[2] = vposition.z;
    position[3] = 1.0;
    glLightfv(GL_LIGHT0, GL_POSITION, position);
    
    PVector vdirection = {0, 0, 0};
    vdirection = vnormalize(vsub(vdirection, vposition));
    float direction[4];
    direction[0] = vdirection.x;
    direction[1] = vdirection.y;
    direction[2] = vdirection.z;
    direction[3] = 1.0;
    glLightfv(GL_LIGHT0, GL_SPOT_DIRECTION, direction);
    glLightf(GL_LIGHT0, GL_SPOT_CUTOFF, 45);
    glEnable(GL_LIGHT0);
  
#if 0
    float mcolor[] = { 1.0, 1.0, 1.0, 0 };
    glMaterialfv(GL_FRONT, GL_AMBIENT_AND_DIFFUSE, mcolor);
//    glMaterialfv(GL_BACK, GL_AMBIENT_AND_DIFFUSE, mcolor);
#endif
    
    glEnable(GL_COLOR_MATERIAL);
    glColorMaterial(GL_FRONT, GL_AMBIENT_AND_DIFFUSE);
//    glColorMaterial(GL_BACK, GL_AMBIENT_AND_DIFFUSE);
    
    if(imageTexture) {
        glEnable(GL_TEXTURE_2D);
        glBindTexture(GL_TEXTURE_2D, imageTexture);
        
        glMatrixMode(GL_TEXTURE);
        glRotatef(90, 0, 0, 1);
    }
  
    glEnable(GL_DEPTH);
    glEnable(GL_DEPTH_TEST);
    glFrontFace(GL_CCW);

    [self performSelector:@selector(update:) withObject:nil afterDelay:0.1];
}

-(void)reshape {
    NSRect frame = [self frame];
    glViewport(0, 0, NSWidth(frame), NSHeight(frame));
}

-(void)update:(id)object {
    [self display];
    [self performSelector:@selector(update:) withObject:nil afterDelay:1.0/60.0];
}

PVector normal3(PVector a, PVector b, PVector o) {
    a = vsub(a, o);
    b = vsub(b, o);
    return vnormalize(crossProduct(a, b));
}

- (void)drawRect:(NSRect)rect {
    glClearColor(0, 0, 0, 0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    [page updateParticles:0.05];
 
#if 1
    int neighbors[] = {
        0, 1, meshSize.width+1, meshSize.width
    };
    Particle *c = [page particles];
   
    double x0 = c->p0.x;
    double y0 = c->p0.y;
    
    glBegin(GL_QUADS);
    int ci = 0;
    for(int y = 0; y < meshSize.height-1; y++) {
        for(int x = 0; x < meshSize.width-1; x++) {
            if(!imageTexture)
                glColor3f(blockColors[ci].r, blockColors[ci].g, blockColors[ci].b);
            ci++;

#if 0
            PVector n = normal3((c+neighbors[1])->p, (c+neighbors[3])->p, c->p);
//            glNormal3dv((double*)&n);
#else
            Particle *particles = [page particles];
            PVector normals[4];
            int normalIndex = 0;
            static int nneigborsX[] = {0, -1, 0, 1};
            static int nneigborsY[] = {1, 0, -1, 0};
            for(int i = 0; i < 4; i++) {
                int nx = x + nneigborsX[i];
                int ny = y + nneigborsY[i];
                Particle *p1 = NULL;
                if(nx >= 0 && ny >= 0 && nx < meshSize.width && ny < meshSize.height)
                    p1 = particles+ny*(int)meshSize.width+nx;
                
                nx = x + nneigborsX[(i+1)%4];
                ny = y + nneigborsY[(i+1)%4];
                Particle *p2 = NULL;
                if(nx >= 0 && ny >= 0 && nx < meshSize.width && ny < meshSize.height)
                    p2 = particles+ny*(int)meshSize.width+nx;
                if(p1 && p2)
                    normals[normalIndex++] = normal3(p1->p, p2->p, c->p);
            }
            PVector normalSum = normals[0];
            for(int i = 1; i < normalIndex; i++)
                normalSum = vadd(normalSum, normals[i]);
            PVector n = vnormalize(vmulConst(normalSum, 1.0/(double)normalIndex));
#endif
            for(int i = 0; i < 4; i++) {
                Particle *p = c+neighbors[i];
                glNormal3dv((double*)&n);
                if(imageTexture)
                    glTexCoord2f((p->p0.x-x0), (p->p0.y-y0));
                glVertex3f(p->p.x, p->p.y, p->p.z);
            }
            c++;
        }
        c++;
    }
    glEnd();
#else
    glBegin(GL_QUADS);
    glTexCoord2f(0, 0); glVertex2f(-1, -1);
    glTexCoord2f(1, 0); glVertex2f(1, -1);
    glTexCoord2f(1, 1); glVertex2f(1, 1);
    glTexCoord2f(0, 1); glVertex2f(-1, 1);
    glEnd();
#endif
    [[self openGLContext] flushBuffer];
}

#if 1
/*
 x^2/a^2 + y^2/b^2 = 1
 */
- (void)mouseMoved:(NSEvent *)theEvent {
//    if(!mouseParticle) return;
    NSPoint mouse = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    
    double x = mouse.x*2.0;
    if(fabs(mouse.x*2.0) > 1.0)
        x = (x>=0 ? 1.0 : -1.0);

    PVector mousePosition;
    mousePosition.x = x;
//    mouseParticle->p.y = mouse.y*2.0;
    if(fabs(x) < 2.0)
        mousePosition.z = sqrt(fabs((1.0 - x*x/1.0)*.75));
//    mouseParticle->fixed = true;

    [page pullAtPoint:mousePosition];
#if 0
    if(mouseParticle2) {
        mouseParticle2->p.x = mouse.x*2.0;
        mouseParticle2->p.y = (mouse.y+(mouseParticle2->p0.y-mouseParticle->p0.y))*2.0;
        mouseParticle2->fixed = true;
    }
#endif

    [self setNeedsDisplay:YES];
}

- (void)scrollWheel:(NSEvent *)theEvent {
    if(!mouseParticle) return;
    mouseParticle->p.z -= [theEvent deltaY]/20.0;
    if(mouseParticle2)
        mouseParticle2->p.z -= [theEvent deltaY]/20.0;
}

#endif

@end
