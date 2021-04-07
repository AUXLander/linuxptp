#pragma once

#include <stdlib.h>
#include <string.h>

#include "filter_private.h"

struct cfilter
{
	struct filter filter;

    int index;

    int64_t  state;
    double covariance;
};

tmv_t cfilter_callback(struct filter *filter, tmv_t sample);

struct filter *cfilter_create();

void cfilter_reset(struct filter *filter);
void cfilter_destroy(struct filter *filter);
void cfilter_set_start(struct cfilter *m, tmv_t* sample);