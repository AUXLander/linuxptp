#include "cfilter.h"

tmv_t cfilter_callback(struct filter *filter, tmv_t sample)
{
    struct cfilter *m = container_of(filter, struct cfilter, filter);

    if (m->index == 0)
    {
        cfilter_set_start(m, &sample);
    }

    const double Q = 2.0;
    const double R = 15.0;
    const double F = 1.0;
    const double H = 1.0;

    const int64_t X0 = (int64_t)(F * m->state);
    const double  P0 = F * m->covariance * F + Q;
    const double  K  = H * P0 / (H * P0 * H + R);

    m->state = X0 + (int64_t)(K * (sample.ns - (int64_t)(H * X0)));
    m->covariance = (1.0 - K*H) * P0;

    m->index = m->index + 1;

    tmv_t time;

    time.ns = m->state;
    
    return time;
}

void cfilter_set_start(struct cfilter *m, tmv_t* sample)
{
    if (sample != NULL)
    {
        m->state = (*sample).ns;
    }
    else
    {
        m->index = 0;
    }

    m->covariance = 0.1;
}

void cfilter_destroy(struct filter *filter)
{
	struct cfilter *m = container_of(filter, struct cfilter, filter);

	free(m);
}

void cfilter_reset(struct filter *filter)
{
	struct cfilter *m = container_of(filter, struct cfilter, filter);

    cfilter_set_start(m, NULL);
}

struct filter *cfilter_create()
{
	pr_notice("cfilter start");

    struct cfilter *m;

	m = calloc(1, sizeof(*m));

	if (!m)
    {
        return NULL;
    }

	m->filter.destroy = cfilter_destroy;
	m->filter.sample  = cfilter_callback;
	m->filter.reset   = cfilter_reset;

    cfilter_set_start(m, NULL);

	return &m->filter;
}