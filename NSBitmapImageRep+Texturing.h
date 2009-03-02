//
//  NSBitmapImageRep+Texturing.h
//  PageFlip
//
//  Created by Sean Miceli on 1/25/09.
//  Copyright 2009 CoolThingsMade. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSBitmapImageRep (Texturing) 

-(void)copyToGLTexture:(int)textureName;

@end
