describe 'List', ->
	Emp = roller.Emp
	List = roller.List

	describe 'add', ->
		it 'adds an element to an empty list', ->
			list = Emp.add 123
			(expect list.value).toEqual 123
			(expect list.next).toEqual Emp

		it 'adds an element to a non-empty list', ->
			list = (Emp.add 123).add 456
			(expect list.value).toEqual 456
			(expect list.next.value).toEqual 123
			(expect list.next.next).toEqual Emp


	describe 'find', ->
		it 'returns null for an empty list', ->
			(expect Emp.find -> true).toBeNull()

		it 'returns an element if the predicate holds', ->
			subList = Emp.add 123
			list = subList.add 456
			(expect list.find (value) -> value == 123).toBe subList

		it 'returns null if the predicate never holds', ->
			subList = Emp.add 123
			list = subList.add 456
			(expect list.find (value) -> value == 789).toBeNull()