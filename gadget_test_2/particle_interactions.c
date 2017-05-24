//
//  particle_interactions.c
//  gadget_test_2
//
//  Created by Peter Lee on 8/5/15.
//  Copyright (c) 2015 Peter Lee. All rights reserved.
//
//  A routine that modifies the acceleration of all particles with respect to
//  a specified touch location on the graphical interface
//
//  This routine no longer modifies acceleration, or any parameters used to calculate
//  time steps, it now uses an "added velocity" parameter so that the particles can
//  be moved without changing their velocity while giving the ability to break apart
//  galaxies
//

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "allvars.h"

void modify_accel() {
    
    float maxvel = pow(10.0,9.0);
    float softening = 500.0; // to avoid infinite acceleration
    float bound = pow(10.0,5.0);
    float halfbound = bound *.5;
    
    //for (int i = 1; i <= NumPart; i++) P[i].Vel[2] = 0;
    
    if (interaction == 0){
        for(int i = 1; i <= NumPart; i++) {
            P[i].addedVel[0] = P[i].Vel[0];
            P[i].addedVel[1] = P[i].Vel[1];
        }
        // no current interactions
        return;
    }
    
    // > 0 for attractive, < 0 for repulsive
    float attractionFactor = 10000000000.0 * interactionFactor;
    accelerationFactor = attractionFactor;
    
    float touchX = touchLocation[0];
    float touchY = touchLocation[1];
    float touchZ = touchLocation[2];
    
    printf("touch: %f %f %f\n", touchX, touchY, touchZ);
    
    float partX = 0;
    float partY = 0;
    
    float deltaX = 0;
    float deltaY = 0;
    
    float dist = 0;
    
    float accelMag = 0;
    float accelX = 0;
    float accelY = 0;
    float velmag = 0;
    float velX = 0;
    float velY = 0;
    
    // update the acceleration for each particle
    // Note: particle indexing is [1, n] in original GADGET code for some weird reason
    // oh Fortran
    for (int i = 1; i <= NumPart; i++) {
        partX = P[i].Pos[0];
        partY = P[i].Pos[1];
        //float partZ = P[i].Pos[2];
        
        // distance from touch to particle
        
        deltaX = (touchX - partX);
        deltaY = (touchY - partY);
        if(fabsf(deltaX)>halfbound){
            deltaX = (bound-fabsf(deltaX))*copysign(1.0,-deltaX);
        }
        if(fabsf(deltaY)>halfbound){
            deltaY = (bound-fabsf(deltaY))*copysign(1.0,-deltaY);
        }
        //float deltaZ = (touchZ - partZ);
        //float dist = sqrt(deltaX * deltaX + deltaY * deltaY + deltaZ * deltaZ) + softening;
        dist = sqrt(deltaX * deltaX + deltaY * deltaY) + softening;
        
        accelMag = attractionFactor / (dist * dist);
        accelX = accelMag * (deltaX / dist);
        accelY = accelMag * (deltaY / dist);
        //float accelZ = accelMag * (deltaZ / dist);
        
        velX = P[i].Vel[0] += accelX;
        velY = P[i].Vel[1] += accelY;
        
        velmag = sqrt(velX*velX + velY*velY);
        
        if(velmag>maxvel){
            velX = maxvel*velX/velmag;
            velY = maxvel*velY/velmag;
        }
        
        P[i].Vel[0] = velX;
        P[i].Vel[1] = velY;
        
        P[i].Accel[2] = 0;
    }
    /*
     } else {
    
        for (int i = 1; i <= NumPart; i++) {
            float range = 10000.0;
            float partX = P[i].Pos[0];
            float partY = P[i].Pos[1];
            
            float dist = sqrt((partX-touchX)*(partX-touchX)+(partY-touchY)*(partY-touchY));
            if(range - dist >= 0.0) {
                P[i].Pos[0] += 100.0 * (partX-touchX) / dist;
                P[i].Pos[1] += 100.0 * (partY-touchY) / dist;
            }
        } */
    
}
