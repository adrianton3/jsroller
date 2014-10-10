getUnaryBuilder = (prefix = '') ->
	cache = [prefix]

	(n) ->
		if n < cache.length
			cache[n]
		else
			accumulator = cache[cache.length - 1]
			for i in [cache.length..n]
				accumulator += '_'
				cache[i] = accumulator
			accumulator


getBinaryBuilder = (prefix = '') ->
	cache = ['_']

	build = (n) ->
		string = ''
		while n
			string = (if n % 2 then '$' else '_') + string
			n //= 2
		string

	(n) ->
		if n < cache.length
			cache[n]
		else
			for i in [cache.length..n]
				cache[i] = build i
		console.log cache
		cache[n]



window.roller ?= {}
window.roller.getUnaryBuilder ?= getUnaryBuilder
window.roller.getBinaryBuilder ?= getBinaryBuilder