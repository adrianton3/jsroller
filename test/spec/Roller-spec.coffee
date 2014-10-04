describe 'Roller', ->
	describe 'getLevelInfo', ->
		getLevelInfo = (source) ->
			tree = esprima.parse source
			roller.getLevelInfo tree

		beforeEach ->
			jasmine.addMatchers CustomMatchers

		describe 'variables', ->
			getLocalVars = (source) ->
				{ localVars, _, _, _, _ } = getLevelInfo source
				localVars

			it 'retrieves local vars', ->
				expect getLocalVars 'var a, b, c;'
				.toEqualSet new Set ['a', 'b', 'c']

			it 'retrieves local vars from inside blocks', ->
				expect getLocalVars 'if (true) { var a, b, c; }'
				.toEqualSet new Set ['a', 'b', 'c']

			it 'retrieves function declarations', ->
				expect getLocalVars 'function f() {}'
				.toEqualSet new Set ['f']

			it 'does not retrieve named function expressions', ->
				expect getLocalVars '(function f() {})'
				.toEqualSet new Set

			it 'does not retrieve vars from inside functions', ->
				expect getLocalVars 'function f() { var a, b, c; }'
				.toEqualSet new Set ['f']

			it 'does not retrieve labels', ->
				expect getLocalVars 'var a = { b: 0 }'
				.toEqualSet new Set ['a']


		describe 'variable identifiers', ->
			getVarIds = (source) ->
				{ _, varIds, _, _, _ } = getLevelInfo source
				varIds.map (entry) -> entry.name

			it 'does not retrieve object labels', ->
				expect getVarIds 'var a = { b: 0 }'
				.toEqual ['a']


	describe 'obfuscate', ->
		trimWS = (text) ->
			(text.replace /\n/g, ' ').replace /\s{2,}/g, ' '

		obfuscate = (source) ->
			trimWS roller.obfuscate source, { headers: false }


		describe 'literals', ->
			it 'obfuscates a number literal', ->
				(expect obfuscate '123').toEqual '__._;'

			it 'obfuscates a string literal', ->
				(expect obfuscate '"asd"').toEqual '__._;'

			it 'obfuscates a boolean literal', ->
				(expect obfuscate 'true').toEqual '__._;'

			it 'obfuscates two distinct literals', ->
				(expect obfuscate '123; 456;').toEqual '__._; __.__;'

			it 'obfuscates the same literal multiple times', ->
				(expect obfuscate '123; 123;').toEqual '__._; __._;'


		describe 'variables', ->
			it 'obfuscates a local variable', ->
				(expect obfuscate 'var a;').toEqual 'var ______;'

			it 'obfuscates two local variables from the same declaration', ->
				(expect obfuscate 'var a, b;').toEqual 'var ______, _______;'

			it 'obfuscates the same variable twice from the same declaration', ->
				(expect obfuscate 'var a, a;').toEqual 'var ______, ______;'

			it 'does not obfuscate \'arguments\'', ->
				expect obfuscate 'function f() { arguments; }'
				.toEqual 'function ______() { arguments; }'

			it 'obfuscates \'arguments\' if it\'s declared locally', ->
				expect obfuscate 'function f() { var arguments; }'
				.toEqual 'function ______() { var _______; }'

			it 'preserves shadowing', ->
				expect obfuscate 'var a; function f() { var a; }'
				.toEqual 'var ______; function _______() { var ______; }'

			it 'obfuscates global variables', ->
				(expect obfuscate 'a;').toEqual '___._;'

			it 'obfuscates \'window\'', ->
				(expect obfuscate 'window;').toEqual '___;'

			it 'preserves distinct namespaces', ->
				expect obfuscate 'function f(a) { } function g(b) { }'
				.toEqual 'function ______(________) { } function _______(________) { }'


		describe 'functions', ->
			it 'obfuscates a function\'s name inside a function declaration', ->
				expect obfuscate 'function a() { }'
				.toEqual 'function ______() { }'

			it 'obfuscates a function\'s formal parameters', ->
				expect obfuscate 'function f(a, b) { }'
				.toEqual 'function ______(_______, ________) { }'


		describe 'member expressions', ->
			it 'obfuscates a member expression', ->
				(expect obfuscate 'a.b;').toEqual '___._[_._];'

			it 'obfuscates the same property twice', ->
				(expect obfuscate 'a.b.b;').toEqual '___._[_._][_._];'