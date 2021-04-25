#pragma once

#include "print.h"
#include "msg.h"

#include "randvardistribution/src/liblinkshared.h"


enum noise_type
{
    uniform_noise = 1,
    poisson_noise = 2,
    normal_noise  = 3
};

int noiseEnable;
enum noise_type noise;

void track(struct ptp_message *msg);