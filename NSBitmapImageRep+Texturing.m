//
//  NSBitmapImageRep+Texturing.m
//  PageFlip
//
//  Created by Sean Miceli on 1/25/09.
//  Copyright 2009 CoolThingsMade. All rights reserved.
//

#import "NSBitmapImageRep+Texturing.h"

#import <OpenGL/OpenGL.h>


@implementation NSBitmapImageRep (Texturing)

-(void)copyToGLTexture:(int)textureName {
    glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
    glBindTexture(GL_TEXTURE_2D, textureName);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    
    GLuint format = [self hasAlpha] ? GL_RGBA : GL_RGB;
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, [self pixelsWide], [self pixelsHigh], 0, format, GL_UNSIGNED_BYTE, [self bitmapData]);
}

@end
