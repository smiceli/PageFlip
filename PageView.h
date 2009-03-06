//
//  PageView.h
//  PageFlip
//
//  Created by Sean Miceli on 1/25/09.
//  Copyright 2009 CoolThingsMade. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Page.h"

@interface PageView : NSOpenGLView {
    GLuint imageTexture;
    Page *page;
    CGSize meshSize;
    Particle *mouseParticle;
    Particle *mouseParticle2;
}

-(void)update:(id)object;

@end
