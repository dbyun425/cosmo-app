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
/*
 
 Rewritten and updated to allow for the press accelearton calculation to be
 either the actual press or a virtual press, whichever is closer.  Virtual
 press is a press which is closer to particle due to the toroidal nature
 of the space in the simulation.
 
 Removes feature of tearing apart galaxies efficiently. 5/23/17

 */
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "allvars.h"

float mod_dist(float delx, float dely, float softening){
    /* Returns a softened distance between particle and press (to avoid div0) */
    return sqrtf(delx*delx+dely*dely)+softening;
}

float force_press(float accelfac, float dist){
    /* Returns the "force" by press on particles */
    return accelfac/(dist*dist);
}

float get_comp(float force, float comp, float dist){
    /* Returns a component of acceleration */
    return force*(comp/dist);
}

void modify_accel(){
    /* Modifies velocity of particles on screenpress */
    
    //No keypress
    if(interaction == 0) return;
    
    //A limiting maximum velocity
    float maxvel = pow(10.0,9.0);

    //Attractive/Repulsive is +/- respectively
    float attractFactor = pow(10.0,11.0) * interactionFactor;
    accelerationFactor = -attractFactor;
    
    //Touch coords
    float touchX = touchLocation[0];
    float touchY = touchLocation[1];
    
    float softening = 500.0; // to avoid infinite acceleration
    float bound = pow(10.0,5.0); //Boundary of space (max)
    float halfbound = bound*.5;
    float maxradius = bound/3.0; //Max radius of force tool
    
    //printf("touch: %f %f %f\n", touchX, touchY);
    
    // Update the acceleration for each particle
    // Note: particle indexing is [1, n] in origianl GADGET code for some weird
    // reason
    // Blame Fortran?
    for (int i = 1; i <= NumPart; i++) {
        //Particle Coords
        float partX = P[i].Pos[0];
        float partY = P[i].Pos[1];
        
        //Part True Dist
        float delX = (partX - touchX)*-1.0;
        float delY = (partY - touchY)*-1.0;
        
        if(fabsf(delX)>halfbound){
            delX = (bound-fabsf(delX))*copysign(1.0,-delX);
        }
        if(fabsf(delY)>halfbound){
            delY = (bound-fabsf(delY))*copysign(1.0,-delY);
        }
        
        softening = sqrtf(delX*delX+delY*delY);
        
        float dist = mod_dist(delX, delY, softening);
        
        //if(dist > maxradius) continue;
        
        //"Forces" from press
        float fpart = force_press(attractFactor, dist);
        
        //Acceleration Components
        float accelX = get_comp(fpart, delX, dist);
        float accelY = get_comp(fpart, delY, dist);
        
        //grab velocities
        float Vx = P[i].Vel[0];
        float Vy = P[i].Vel[1];
        
        //Update velocities
        Vx += accelX;
        Vy += accelY;
        
        //Magnitude of velocities
        float magV = pow(Vx,2.0)+pow(Vy,2.0);
        
        //Check for exceeding "lightspeed"
        if(magV>maxvel){
            Vx = Vx * (maxvel/magV);
            Vy = Vy * (maxvel/magV);
        }
        
        //Update Velocities
        P[i].Vel[0] = Vx;
        P[i].Vel[1] = Vy;
        
        //Pin z axis
        P[i].Accel[2] = 0;
    }
}

/*
float rev_dist_comp(float aval, float bval){
    float maxbound = 100000.0;
    return aval < bval ? aval + (maxbound-bval) : maxbound + bval - aval;
}

void modify_accel() {
    //for (int i = 1; i <= NumPart; i++) P[i].Vel[2] = 0;
    float maxvel = 1000000000.0;
    
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
    
    // update the acceleration for each particle
    // Note: particle indexing is [1, n] in origianl GADGET code for some weird reason
    for (int i = 1; i <= NumPart; i++) {
        float partX = P[i].Pos[0];
        float partY = P[i].Pos[1];
        //float partZ = P[i].Pos[2];
        
        // distance from touch to particle
        float softening = 500.0; // to avoid infinite acceleration
        float deltaX = (touchX - partX);
        float deltaY = (touchY - partY);
        //float deltaZ = (touchZ - partZ);
        //float dist = sqrt(deltaX * deltaX + deltaY * deltaY + deltaZ * deltaZ) + softening;
        float dist = sqrt(deltaX * deltaX + deltaY * deltaY) + softening;

        //ReverseDistance
        float drevx = 0.0;
        float drevy = 0.0;
        
        drevx = rev_dist_comp(partX, touchX);
        drevy = rev_dist_comp(partY, touchY);
        float drevdist = sqrt(pow(drevx,2.0)+pow(drevy,2.0))+softening;
        float oppaccel = attractionFactor / pow(drevdist,2.0);
        float accelMag = attractionFactor / pow(dist,2.0);
        printf("%f\n",drevdist);
        printf("%f\n\n",dist);
        accelMag += oppaccel;
        float accelX = accelMag * (deltaX / dist);
        float accelY = accelMag * (deltaY / dist);
        //float accelZ = accelMag * (deltaZ / dist);
        
        P[i].Vel[0] += accelX;
        P[i].Vel[1] += accelY;
        float Vx = P[i].Vel[0];
        float Vy = P[i].Vel[1];
        float magV = pow(Vx,2.0)+pow(Vy,2.0);
        
        if(magV>maxvel){
            Vx = Vx * (maxvel/magV);
            Vy = Vy * (maxvel/magV);
            P[i].Vel[0] = Vx;
            P[i].Vel[1] = Vy;
        }
        
        //P[i].Pos[0] += P[i].Vel[0] * 0.000001;
        //P[i].Pos[1] += P[i].Vel[1] * 0.000001;
        P[i].Accel[2] = 0;
    }
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
