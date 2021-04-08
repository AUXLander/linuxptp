#include "cfilter.h"

tmv_t cfilter_callback(struct filter *filter, tmv_t sample)
{
    struct cfilter *m = container_of(filter, struct cfilter, filter);

    const double Q = 2.0;
    const double R = 15.0;
    const double F = 1.0;
    const double H = 1.0;

    const int64_t X0 = (int64_t)(F * m->state);
    const double  P0 = F * m->covariance * F + Q;
    const double  K  = H * P0 / (H * P0 * H + R);

    m->state = X0 + (int64_t)(K * (sample.ns - (int64_t)(H * X0)));
    m->covariance = (1.0 - K*H) * P0;

    pr_notice("sample = %+5" PRId64, sample.ns);
    pr_notice("state  = %+5" PRId64, m->state);
    pr_notice("sub    = %+5" PRId64, sample.ns - m->state);

    if (m->index > 0)
    {
        sample.ns = m->state;
    }

    m->index = m->index + 1;
    
    return sample;
}

void cfilter_set_start(struct cfilter *m, tmv_t* sample)
{

}

void cfilter_destroy(struct filter *filter)
{
	struct cfilter *m = container_of(filter, struct cfilter, filter);

	free(m);
}

void cfilter_reset(struct filter *filter)
{
	struct cfilter *m = container_of(filter, struct cfilter, filter);
    
    m->covariance = 0.1;
    m->index = 0;
}

struct filter *cfilter_create()
{
	pr_notice("calman filter start");

    struct cfilter *m;

	m = calloc(1, sizeof(*m));

	if (!m)
    {
        return NULL;
    }

	m->filter.destroy = cfilter_destroy;
	m->filter.sample  = cfilter_callback;
	m->filter.reset   = cfilter_reset;

    m->covariance = 0.1;
    m->index = 0;

	return &m->filter;
}