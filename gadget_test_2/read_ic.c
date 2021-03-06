#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

#include "allvars.h"
#include "proto.h"


/* This function reads initial conditions that are in the default file format
 * of Gadget, i.e. snapshot files can be used as input files.
 * However, when a snapshot file is used as input, not all the information
 * in the header is used: THE STARTING TIME NEEDS TO BE SET IN THE
 * PARAMETERFILE
 *
 * Alternatively, the code can be started with restartflag==2, then
 * snapshots from the code can be used as initial conditions-files
 * without having to change the parameterfile.
 *
 * For gas particles, only the internal energy is read, the density and mean
 * molecular weight will be recomputed by the code.
 *
 * When InitGasTemp>0 is given, the gas temperature will be initialzed to this
 * value assuming a mean colecular weight of 1.
 *
 * Modifications include when reading in certain initial conditions to make sure 
 * that only one slice has been taken, and that the z components are all 0 as
 * well as instantiating the addedVel parameter
 */
void read_ic(char *fname)
{
#define SKIP my_fread(&blklen,sizeof(int4byte),1,fd);
    FILE *fd;
    int   i,k,massflag,count;
    float dummy[3];
    int   pc,type ;
    int4byte  intdummy, blklen;
    double u_init;
    
    if((fd=fopen(fname,"r")))
    {
        fprintf(stdout,"Reading file '%s'\n",fname); fflush(stdout);
        
        SKIP;
        if(blklen!=256)
        {
            printf("incorrect header format (1)\n");
            endrun(888);
        }
        my_fread(&header1,sizeof(header1),1,fd);
        SKIP;
        if(blklen!=256)
        {
            printf("incorrect header format (2)\n");
            endrun(889);
        }
        
        All.TotN_gas  = N_gas  = header1.npart[0];
        All.TotN_halo = header1.npart[1];
        All.TotN_disk = header1.npart[2];
        All.TotN_bulge= header1.npart[3];
        All.TotN_stars= header1.npart[4];
        
        if(RestartFlag==2)
        {
            All.Time = All.TimeBegin = header1.time;
        }
        
        for(i=0, massflag=0;i<5;i++)
        {
            All.MassTable[i]= header1.mass[i];
            if(All.MassTable[i]==0 && header1.npart[i]>0)
                massflag=1;
        }
        
        printf("\nN_sph: %d\nN_halo: %d\nN_disk: %d\nN_bulge: %d\nN_stars: %d\n",
               All.TotN_gas, All.TotN_halo, All.TotN_disk, All.TotN_bulge, All.TotN_stars);
        
        NumPart = All.TotNumPart =    All.TotN_gas  + All.TotN_halo
        + All.TotN_disk + All.TotN_bulge + All.TotN_stars;
        
        All.MaxPart =  All.PartAllocFactor *  All.TotNumPart;    /* sets the maximum number of particles that may
                                                                  reside on a processor */
        All.MaxPartSph=  All.PartAllocFactor * All.TotN_gas;
        
        printf("Numpart=%d\n", NumPart);
        
        allocate_memory();
        
        SKIP;
        for (i = 1; i <= NumPart; i++) {
            my_fread(&dummy[0], sizeof(float), 3, fd);
            
            for (k = 0; k < 3; k++) {
                P[i].Pos[k] = dummy[k];
            }
        }
        SKIP;
        
        
        SKIP;
        //MODIFICATION
        for (i = 1;i <= NumPart; i++) {
            my_fread(&dummy[0],sizeof(float),3,fd);
            
            for (k = 0; k < 3; k++) {
                P[i].Vel[k] = dummy[k];
            }
            P[i].addedVel[0] = 0.0;
            P[i].addedVel[1] = 0.0;
        }
        SKIP;
        
        
        SKIP;
        for(i = 1;i <= NumPart; i++) {
            my_fread(&intdummy, sizeof(int4byte), 1, fd);
            P[i].ID= intdummy;
        }
        SKIP;
        
        
        if (massflag) {
            SKIP;
        }
        for (type = 0, count = 1; type < 5; type++) {
            if(All.MassTable[type]==0 && header1.npart[type]>0) {
                for (i = 1; i <= header1.npart[type]; i++) {
                    my_fread(&dummy[0], sizeof(float), 1, fd);
                    
                    P[count++].Mass = dummy[0];
                }
            }
            else {
                for (i = 1;i <= header1.npart[type]; i++) {
                    P[count++].Mass = All.MassTable[type];
                }
            }
        }
        if (massflag) {
            SKIP;
        }
        
        if (N_gas) {
            SKIP;
            for (i = 1; i <= N_gas; i++) {
                my_fread(&dummy[0], sizeof(float), 1, fd);
                
                SphP[i].EgySpec = dummy[0];
                
            }
            SKIP;
            
            if (RestartFlag == 2) {
                SKIP;
                for (i = 1;i <= N_gas; i++) {
                    my_fread(&dummy[0], sizeof(float), 1, fd);
                    
                    SphP[i].Hsml = dummy[0];
                    
                }
                SKIP;
            }
            
        }
        
        fclose(fd);
        fprintf(stdout,"done with reading.\n"); fflush(stdout);
        
        
        /* set the particle types */
        for(type=0, pc=1; type<5; type++)
            for(i=0; i<header1.npart[type]; i++)
                P[pc++].Type = type;
        
        
        /* ADDITION: trim down the number of particles read in */
        /*
        struct particle_data node = P[1];
        double layer = 32.0;
        double tl = layer * 2.0;
        int i = 1;
        int count = 0;
        while(i < All.TotN_halo){
            if(((All.BoxSize/layer + All.BoxSize/tl - node.Pos[2]) > 0.0)
               && ((All.BoxSize/tl - node.Pos[2]) < 0.0)) {
                count++;
                P[count] = node;
                P[count].Vel[2] = 0;
                P[count].Pos[2] = 0;
                P[count].Mass *= layer;
                //fprintf(stdout,"%f\n",P[count].Pos[2]);
            }
            i++;
            node = P[i];
        }
        fprintf(stdout, "%d\n", count);
        All.TotN_halo = count;
        */
        /* Fixing the values after getting the new count */
        /*
        NumPart = All.TotNumPart =    All.TotN_gas  + All.TotN_halo
        + All.TotN_disk + All.TotN_bulge + All.TotN_stars;
        
        All.MaxPart =  All.PartAllocFactor *  All.TotNumPart;   */
         /* sets the maximum number of particles that may
                                                                  reside on a processor */
        
        //All.MaxPartSph=  All.PartAllocFactor * All.TotN_gas;
        
        /* set temperature if desired */
        
        if(RestartFlag==0)
        {
            if(All.InitGasTemp>0)
            {
                u_init = (1.0/GAMMA_MINUS1)*(BOLTZMANN/PROTONMASS)*All.InitGasTemp;
                u_init*= All.UnitMass_in_g/All.UnitEnergy_in_cgs;      /* unit conversion */  
                
                for(i=1;i<=N_gas;i++) 
                {
                    if(SphP[i].EgySpec==0)
                        SphP[i].EgySpec= u_init;
                }
            }
        }
    }
    else
    {
        fprintf(stdout,"File %s not found.\n", fname); 
        endrun(7);
    }
    
    fprintf(stdout,"Baryonic particles        :  %d\n", N_gas);
    fprintf(stdout,"Collisionless particles   :  %d\n", NumPart-N_gas);
    fprintf(stdout,"                          ----------\n");
    fprintf(stdout,"Total number of particles :  %d\n\n", NumPart);
}












