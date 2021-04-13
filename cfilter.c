#include "cfilter.h"

tmv_t cfilter_callback(struct filter *filter, tmv_t sample)
{
    struct cfilter *m = container_of(filter, struct cfilter, filter);

    const long double Q = 2.0;
    const long double R = 15.0;

    const long double B = 1.0;
    const long double F = 2.0;
    const long double H = 1.0;
    const long double I = 1.0;

    tmv_t Z_kp1 = nanoseconds_to_tmv(F * tmv_to_nanoseconds(m->Zk) + B * tmv_to_nanoseconds(m->Ukpp));
    
    const long double P_kp1 = F * m->Pk * F + Q;

    const long double Kkp1 = P_kp1 * H / (H * P_kp1 * H + R);

    m->Zk = nanoseconds_to_tmv((tmv_to_nanoseconds(Z_kp1) + Kkp1 * (tmv_to_nanoseconds(sample) - H * tmv_to_nanoseconds(Z_kp1)));
    m->Pk = (I - Kkp1 * H) * P_kp1;

    pr_notice("sample = %+5" PRId64, tmv_to_nanoseconds(sample));
    pr_notice("Uk     = %+5" PRId64, tmv_to_nanoseconds(m->Ukpp));
    pr_notice("Zk+1   = %+5" PRId64, tmv_to_nanoseconds(m->Zk));

    if (m->index > 0)
    {

    }
    else
    {
        m->Zk = sample;
        m->Pk = 0.1L;
    }

    m->index = m->index + 1;
    
    return m->Zk;
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

    m->index = 0;

	return &m->filter;
}