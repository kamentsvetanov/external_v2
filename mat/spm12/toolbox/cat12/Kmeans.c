/* ______________________________________________________________________
 *
 * Christian Gaser, Robert Dahnke
 * Structural Brain Mapping Group (http://www.neuro.uni-jena.de)
 * Departments of Neurology and Psychiatry
 * Jena University Hospital
 * ______________________________________________________________________
 * $Id: Kmeans.c 1791 2021-04-06 09:15:54Z gaser $ 
 *
 */

/* This code is a substantially modified version of Tskmeans.C 
 * from Jagath C. Rajapakse
 * 
 * Original author : Jagath C. Rajapakse
 *
 * See:
 * Statistical approach to single-channel MR brain scans
 * J. C. Rajapakse, J. N. Giedd, and J. L. Rapoport
 * IEEE Transactions on Medical Imaging, Vol 16, No 2, 1997
 *
 * Tree structure k-means algorithm
 *
 * Jagath C. Rajapakse (raja@cns.mpg.de) 23-07-97
 */

#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include "Amap.h"

#ifdef MATLAB_MEX_FILE
#include <mex.h> 
#endif

double EstimateKmeans(double *src, unsigned char *label, unsigned char *mask, int n_classes, double *mean, int ni, int *dims, int thresh_mask, int thresh_kmeans, double min_src, double max_src)
/* perform k-means algorithm give initial mean estimates */    
{
  int i, j, j0, v;
  int count;
  long histo[256], lut[256], cumsum[256], vol;
  double diff, dmin, dx, xnorm, sum;

  vol  = dims[0]*dims[1]*dims[2];

  /* build intensity histogram */
  for (i = 0; i < 256; i++) histo[i] = 0;
  for (i = 0; i < vol; i++) {
    v = (int)ROUND(255.0*(src[i]-min_src)/(max_src-min_src));
    if (v < 1) continue;
    if ((thresh_mask > 0) && ((int)mask[i] < thresh_kmeans))
      continue;
    if (v < 0) v = 0;
    if (v > 255) v = 255; 
    histo[v]++;  
  }

  /* use only value in histogram where cumsum is between 1..99% */
  cumsum[0] = histo[0];
  for (i = 1; i < 256; i++) cumsum[i] = cumsum[i-1] + histo[i];
  for (i = 0; i < 256; i++) cumsum[i] = (long) ROUND(1000.0*(double)cumsum[i]/(double)cumsum[255]);
  for (i = 0; i < 256; i++) if ((cumsum[i] <= 10) || (cumsum[i] >= 990)) histo[i] = 0;

  /* loop through */
  diff = HUGE;  count = 0;
  while (diff > 1.0 && count < ni) {

    /* assign class labels */
    for (i = 0; i < 256; i++) {
      dmin = 256.0 * 256.0;
      for (j = 0; j < n_classes; j++) {
        dx = (double) i - mean[j];
        dx *= dx;
        if (dx < dmin) {
          lut[i] = j;
          dmin = dx;
        }
      }
    }

    /* find the new cluster centers */
    diff = 0;
    for (i = 0; i < n_classes; i++) {
      xnorm = 0.0;
      sum = 0.0;
      for (j = 0; j < 256; j++)
      if (lut[j] == i) {
        xnorm += histo[j];
        sum +=  j * histo[j];
      }
      sum = xnorm > 0 ? sum /= xnorm : 0.0;
      dx = sum - mean[i];
      mean[i] = sum;
      dx *= dx;
      diff += dx;
    }
    count++;
  }

  /* assign final labels to voxels */
  for (i = 0; i < 256; i++) {
    dmin = HUGE;
    j0 = 0;
    for (j = 0; j < n_classes; j++) {
      if (fabs((double) i - mean[j]) < dmin) {
        dmin = fabs((double)i - mean[j]);
        j0 = j;
      }
    }
    lut[i] = j0;
  }
  
  lut[0] = 0;

  /* adjust for the background label */
  diff = 0;
  
  for (i = 0; i < vol; i++) {
    v = (int)ROUND(255.0*(src[i]-min_src)/(max_src-min_src));
    if (v >= 1) {
      if (v < 0) v = 0;
      if (v > 255) v = 255;
      label[i] = (unsigned char)(lut[v] + 1); 
      diff += SQR((double)v - mean[lut[v]]);
      if ((thresh_mask > 0) && ((int)mask[i] < thresh_mask))
        label[i] = 0; 
    }
    else label[i] = 0;  
  }
  
  /* return square error */
  return(diff);
}

double Kmeans(double *src, unsigned char *label, unsigned char *mask, int NI, int n_clusters, double *voxelsize, int *dims, int thresh_mask, int thresh_kmeans, int iters_nu, int pve, double bias_fwhm)
{
  double e, emin, eps, *nu, *src_bak, th_src, val, sum;
  double last_err = HUGE;
  double min_src = HUGE, max_src = -HUGE;
  double fwhm[3];
  double mean[MAX_NC];
  double var;
  double mu[MAX_NC];
  double Mu[MAX_NC];
  long   n[MAX_NC];
  long   vol, i;
  int    j, k, subsample, masked_smoothing;
  int    n_classes, count_err, count;
  int    n_classes_initial = n_clusters;

  vol  = dims[0]*dims[1]*dims[2];

  src_bak = (double *)malloc(sizeof(double)*vol);
  if(src_bak == NULL) {
    printf("Memory allocation error\n");
    exit(EXIT_FAILURE);
  }
  
  if (iters_nu > 0) {
    nu = (double *)malloc(sizeof(double)*vol);
    if(nu == NULL) {
      printf("Memory allocation error\n");
      exit(EXIT_FAILURE);
    }
  }  
        
  /* find minimum and maximum and mean inside mask */
  for (i = 0; i < vol; i++) {
    if (mask[i] > 0) {
      min_src = MIN(src[i], min_src);
      max_src = MAX(src[i], max_src);
    }
  }
   

  /* PVE labeling */
  if (pve == KMEANS) {
    n_classes_initial = 3;
    n_clusters += 3;
  }

  /* go through all sizes of cluster beginning with two clusters */
  for (n_classes=2; n_classes <= n_classes_initial; n_classes++) {

    if (n_classes == 2) {
      /* initialize for the two cluster case; */
      n[0]=0; mean[0] = 0.0; var = 0.0;

      for (i = 0; i < vol; i++) {
        val = 255.0*(src[i]-min_src)/(max_src-min_src);
        if (val < 1.0/255.0) continue;
        n[0]++;
        mean[0] += val;
        var  += SQR(val);
      }
      
      Mu[0] = n[0] != 0 ? mean[0]/n[0]: 0.0;
      var = n[0] > 1 ? (var - n[0]*Mu[0]*Mu[0])/(n[0] - 1.0) : 1.0;
      eps = 0.5*sqrt(var);
    }
    else {
      /* find the deviant (epsilon) for the node being divided */
      eps = Mu[0];
      for (i = 0; i < n_classes-2; i++)
        if (Mu[i+1] - Mu[i] < eps)
          eps = Mu[i+1] - Mu[i];
      if (255 - Mu[n_classes-2] < eps)
        eps = 255 - Mu[n_classes-2];
      eps = eps*0.5;
    }

    /* go through low order clustering */
    emin = HUGE;
    for (k = 0; k < n_classes-1; k++) {
      for (i = n_classes-1; i > k+1; i--) mean[i] = Mu[i-1];
      mean[k+1] = Mu[k] + eps;  mean[k] = Mu[k] - eps;
      for (i = 1; i < k; i++) mean[i] = Mu[i];
      e = EstimateKmeans(src, label, mask, n_classes, mean, NI, dims, thresh_mask, thresh_kmeans, min_src, max_src);
      if (e < emin) {
        emin = e;
        for (i = 0; i < n_classes; i++) 
          mu[i] = mean[i];
      }
    }
    for (i = 0; i < n_classes; i++) Mu[i] = mu[i];     
  }
  
  /* extend initial 3 clusters to 6 clusters by averaging clusters */
  if (pve == KMEANS) {
    mu[0] = Mu[0]/2.0;
    mu[1] = Mu[0];
    mu[2] = (Mu[0]+Mu[1])/2.0;
    mu[3] = Mu[1];
    mu[4] = (Mu[1]+Mu[2])/2.0;
    mu[5] = Mu[2];
  }

  /* find the final clustering and correct for nu */
  if (iters_nu > 0) {

    printf("Nu correction\n");

    /* only use values above the mean of the lower two clusters for nu-estimate */
    th_src = (max_src-min_src)*(double)((Mu[0]+Mu[1])/2.0)/255.0;

    /* save values of previous iteration */
    for (i = 0; i < vol; i++) src_bak[i] = src[i];
    e = EstimateKmeans(src, label, mask, n_clusters, mu, NI, dims, thresh_mask, thresh_kmeans, min_src, max_src);
    count_err = 0;
    for (j = 0; j < iters_nu; j++) {  
      for (i = 0; i < vol; i++) {
        nu[i] = 0.0;
        /* only use values above threshold where mask is defined for nu-estimate */
        if (j>(iters_nu - 2)) {
        if (src[i] > th_src)
          nu[i] = src[i]-min_src-((max_src-min_src)/255.0*mu[label[i]-1]);
        } else {
        if (label[i] == (n_classes-1))
          nu[i] = src[i]-min_src-((max_src-min_src)/255.0*mu[label[i]-1]);
        }
      
      }
        /* smoothing of residuals */
        for(i=0; i<3; i++) fwhm[i] = bias_fwhm;
        
        /* use subsampling for faster processing */
        subsample = 2;
        masked_smoothing = 0;

        smooth_subsample_double(nu, dims, voxelsize, fwhm, masked_smoothing, subsample);
      
      /* apply nu correction to source image */
      for (i = 0; i < vol; i++) 
          src[i] -= nu[i];
      
      /* update k-means estimate */
      e = EstimateKmeans(src, label, mask, n_clusters, mu, NI, dims, thresh_mask, thresh_kmeans, min_src, max_src);

fprintf(stderr,"%d: %g\t%g\t%g\n",j,e,last_err,(last_err-e)/e);
      if (e >= last_err)  {
        count_err++;
        /* if Kmeans fails at first iteration of NU correction change parameters and start again */
        if (j==1) {
          count_err = 0;
        }
      }  
      else count_err = 0;
      /* interrupt if last error was for the last 2 iterations larger 
       * or change is < 0.1% */
      if ((count_err > 1) || (((last_err-e)/e < 0.001) && ((last_err-e)/e > 0))) {
        /* rescue old values from previous iteration */
        for (i = 0; i < vol; i++) src[i] = src_bak[i];
        break;
      }

      last_err = e;
    
#if !defined(_WIN32)
/*      printf("iters: %2d error: %7.2f\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b",j+1, e*(double)n_clusters/(double)vol);
      fflush(stdout);
*/#endif    
    
    }    
  } else {
    e = EstimateKmeans(src, label, mask, n_clusters, mu, NI, dims, thresh_mask, thresh_kmeans, min_src, max_src);
  }

  max_src = -HUGE;
  for (i = 0; i < vol; i++)
    max_src = MAX(src[i], max_src);

  if (iters_nu > 0) printf("\n");
/*  printf("K-Means: ");
  for (i = 0; i < n_clusters; i++) printf("%3.3f ",max_src*mu[i]/255.0); 
  printf("\terror: %3.3f\n",e*(double)n_clusters/(double)vol);    
*/
  free(src_bak);
  
  if (iters_nu > 0)
    free(nu);
      
  return(max_src);    
}













