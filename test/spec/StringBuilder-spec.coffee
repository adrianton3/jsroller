describe 'StringUtil', ->
	describe 'UnaryBuilder', ->
		builder = null

		beforeEach ->
			builder = roller.getUnaryBuilder()

		it 'builds a string', ->
			(expect builder 1).toEqual '_'
			(expect builder 5).toEqual '_____'
			(expect builder 2).toEqual '__'

	describe 'BinaryBuilder', ->
		builder = null

		beforeEach ->
			builder = roller.getBinaryBuilder()

		it 'builds a string', ->
			(expect builder 1).toEqual '$'
			(expect builder 5).toEqual '$_$'
			(expect builder 2).toEqual '$_'