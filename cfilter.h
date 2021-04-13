#pragma once

#include <stdlib.h>
#include <string.h>

#include "print.h"
#include "filter_private.h"

struct cfilter
{
	struct filter filter;

    int index;

    tmv_t  Zk; // Z^k
    double Pk;

    tmv_t Ukpp;
};

tmv_t cfilter_callback(struct filter *filter, tmv_t sample);

struct filter *cfilter_create();

void cfilter_reset(struct filter *filter);
void cfilter_destroy(struct filter *filter);
void cfilter_set_start(struct cfilter *m, tmv_t* sample);