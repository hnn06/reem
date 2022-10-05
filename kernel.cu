
#include "common.h"
#include "timer.h"
#define coarse_factor 2

__global__ void histogram_private_kernel(unsigned char* image, unsigned int* bins, unsigned int width, unsigned int height) {

    // TODO
    unsigned int i=blockIdx.x*blockDim.x+threadIdx.x;
    

    
    __shared__ unsigned int private_histogram[NUM_BINS];
    if (threadIdx.x<NUM_BINS){
        private_histogram[threadIdx.x]=0;
    }
     __syncthreads();
    
    
    

        
    if(i < width*height) {
        unsigned char b = image[i];
        atomicAdd(&private_histogram[b], 1);
    }
    __syncthreads();
    if (threadIdx.x<NUM_BINS){
        atomicAdd(&bins[threadIdx.x],private_histogram[threadIdx.x]);
    }
    
    
    
}

void histogram_gpu_private(unsigned char* image_d, unsigned int* bins_d, unsigned int width, unsigned int height) {

    // TODO
    unsigned int numThreadsPerBlock =1024;
    unsigned int numBlocks=(width*height+numThreadsPerBlock-1)/numThreadsPerBlock;
    histogram_private_kernel<<< numBlocks,numThreadsPerBlock>>> (image_d,bins_d,width,height);
    





}

__global__ void histogram_private_coarse_kernel(unsigned char* image, unsigned int* bins, unsigned int width, unsigned int height) {

    // TODO
    unsigned int i=coarse_factor*blockIdx.x*blockDim.x+threadIdx.x;
    __shared__ unsigned int private_histogram[NUM_BINS];
    
    if (threadIdx.x<NUM_BINS){
        private_histogram[threadIdx.x]=0;
    }
    __syncthreads();
    
    for (unsigned int c=0;c<coarse_factor;++c){
        if(i+c*blockDim.x<width*height){
            unsigned char b = image[i+c*blockDim.x];
            atomicAdd(&private_histogram[b], 1);
        }
    }
    __syncthreads();
    if (threadIdx.x<NUM_BINS){
        atomicAdd(&bins[threadIdx.x],private_histogram[threadIdx.x]);
    }
 
    
              
   
    
        




}

void histogram_gpu_private_coarse(unsigned char* image_d, unsigned int* bins_d, unsigned int width, unsigned int height) {

    // TODO
    unsigned int numThreadsPerBlock =1024;
    unsigned int numBlocks=(width*height+(numThreadsPerBlock*coarse_factor)-1)/(numThreadsPerBlock*coarse_factor);
    histogram_private_coarse_kernel<<< numBlocks,numThreadsPerBlock>>> (image_d,bins_d,width,height);
    
    





}

