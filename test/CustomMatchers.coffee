CustomMatchers = {}

CustomMatchers.toEqualSet = (util, customEqualityTesters) ->
	compare: (actual, expected) ->
		if actual not instanceof Set
			return pass: false, message: 'Expected a set'

		if actual.size != expected.size
			return pass: false, message: "Expected set to contain #{expected.size} elements but instead got #{actual.size} elements"

		`for (var key of expected) {
			if (!actual.has(key)) {
				return {
					pass: false,
					message: 'Element ' + key + ' is missing from the set'
				}
			}
		}`

		return pass: true


window.CustomMatchers = CustomMatchers