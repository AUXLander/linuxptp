#pragma once

#include <ctime>
#include <random>
#include <cstdint>

class DistributionBase
{
	uint64_t m_min;
	uint64_t m_max;

	uint64_t m_length;

	void __setMinMax(uint64_t minval, uint64_t maxval)
	{
		m_min = 0;
		m_max = 0;

		if (minval < maxval)
		{
			m_min = minval;
			m_max = maxval;
		}

		m_length = m_max - m_min - 1;
	}

protected:
	std::mt19937* generator;

	void inline setMinMax(uint64_t minval, uint64_t maxval)
	{
		return __setMinMax(minval,maxval);
	}

public:
	typedef std::uniform_int_distribution<uint64_t> Uniform;
	typedef std::poisson_distribution<uint64_t>     Poisson;
	typedef std::normal_distribution<float>         Normal;

	const uint64_t& min = m_min;
	const uint64_t& max	= m_max;
	const uint64_t& length = m_length;

	DistributionBase(std::mt19937* const gen) : generator(gen), m_min(0), m_max(0), m_length(0) { }

	virtual void	 init(uint64_t minval, uint64_t maxval) = 0;
	virtual uint64_t next() = 0;
};

template<class T>
class Distribution : public DistributionBase
{
	T* distribution{ nullptr };

	T* distribution_init()
	{
		return nullptr;
	}

	double __next()
	{
		return distribution ? static_cast<double>(distribution->operator()(*generator)) : 0;
	}

public:
	Distribution(std::mt19937* const gen) : DistributionBase(gen) { }
	Distribution(std::mt19937* const gen, uint64_t minval, uint64_t maxval) : DistributionBase(gen) 
	{
		init(minval, maxval);
	}

	void init(uint64_t minval, uint64_t maxval) final
	{
		if (distribution != nullptr)
		{
			delete distribution;
		}

		setMinMax(minval, maxval);

		distribution = distribution_init();
	}

	uint64_t inline next() final
	{
		double _next = __next();

		if (_next > 1.0)
		{
			_next = _next;
		}

		return static_cast<uint64_t>(_next * length);
	}

	~Distribution()
	{
		if (distribution != nullptr)
		{
			delete distribution;
		}
	}
};

template<> DistributionBase::Uniform* Distribution<DistributionBase::Uniform>::distribution_init()
{
	return new DistributionBase::Uniform(0, 1000);
}

template<> double Distribution<DistributionBase::Uniform>::__next()
{
	constexpr double div = 1.0 / 1000.0;

	return static_cast<double>(distribution->operator()(*generator)) * div;
}

template<> DistributionBase::Poisson* Distribution<DistributionBase::Poisson>::distribution_init()
{
	return new DistributionBase::Poisson(10.0);
}

template<> DistributionBase::Normal* Distribution<DistributionBase::Normal>::distribution_init()
{
	return new DistributionBase::Normal(0.5, 1.0);
}