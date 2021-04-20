#include "cfilter.h"

struct cfilter
{
	struct filter filter;

    double (*A)(tmv_t, tmv_t);

    tmv_t  Q;

    tmv_t  bX;
    double bP;

    tmv_t  aX;
    double aP;
    
    uint64_t index;
};

static double matrixA(tmv_t Q, tmv_t X)
{
    return 1.0 + tmv_dbl(Q) / tmv_dbl(X);
}

static void cfilter_update(struct filter *filter, tmv_t offset)
{
    struct cfilter *c = container_of(filter, struct cfilter, filter);

    c->Q = offset;
}

static tmv_t cfilter_sample(struct filter *filter, tmv_t Y)
{
    struct cfilter *c = container_of(filter, struct cfilter, filter);

    const double M_Vk = 10 * 10;
    const double M_Wk = 10 * 10;
    const double M_1_Wk = 1.0 / M_Wk;

    const double C = 1.0;

    if (c->index == 0)
    {
        c->aX = Y;
        c->aP = 0.1;
    }
    else
    {
        const double A = c->A(c->Q, c->aX);

        // A * aX;
        const tmv_t  bX = dbl_tmv(tmv_dbl(c->aX) * A);
        // A * aP * A + M_Vk;
        const double bP = A * c->aP * A + M_Vk;
        // bX + (1.0/((1.0 / bP) + C*M_1_Wk*C)) *C*M_1_Wk*(Y - C*bX);
        const tmv_t  aX = tmv_add(bX, dbl_tmv((1.0 / ((1.0/bP) + C*M_1_Wk*C)) * C * M_1_Wk * tmv_dbl(tmv_sub(Y, dbl_tmv((tmv_dbl(bX) * C))))));
        // 1.0/((1.0/bP) + C*M_1_Wk*C);
        const double aP = 1.0 / ((1.0/bP) + C*M_1_Wk*C);

        //pr_notice("sample = %+5" PRId64, tmv_to_nanoseconds(sample));

        c->bX = bX;
        c->bP = bP;
        c->aX = aX;
        c->aP = aP;
    }

    c->index = c->index + 1;
    
    return c->aX;
}

static void cfilter_destroy(struct filter *filter)
{
	struct cfilter *m = container_of(filter, struct cfilter, filter);

	free(m);
}

static void cfilter_reset(struct filter *filter)
{
	struct cfilter *m = container_of(filter, struct cfilter, filter);
    
    m->index = 0;
}

struct filter *cfilter_create()
{
	pr_notice("calman filter start");

    struct cfilter *c;

	c = calloc(1, sizeof(*c));

	if (!c)
    {
        return NULL;
    }

	c->filter.destroy = cfilter_destroy;
	c->filter.sample  = cfilter_sample;
	c->filter.reset   = cfilter_reset;

    c->Q = nanoseconds_to_tmv(0);
    c->A = matrixA;

    c->index = 0;

	return &c->filter;
}