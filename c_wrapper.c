#include "distribution.hpp"
#include "c_wrapper.h"
#include <map>

static std::mt19937* generator;
static std::random_device device;
static std::map<uint64_t, uint64_t> histogramm;

static Distribution<DistributionBase::Uniform>* uniform;

static int init_v = 0;

uint64_t get_number()
{
	if(init_v == 0)
	{
		generator = new std::mt19937(device());
		
		uniform = new Distribution<DistributionBase::Uniform>(generator, 0, 100);
		
		init_v = 1;
	}
	
	return uniform->next();
}