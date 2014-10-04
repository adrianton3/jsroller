Emp =
	add: (value) -> new List value
	find: (predicate) -> null
	isEmpty: -> true



List = (@value, @next = Emp) ->

List::add = (value) ->
	new List value, @

List::find = (predicate) ->
	if predicate @value
		@
	else
		@next.find predicate

List::isEmpty = -> false



window.roller ?= {}
window.roller.Emp ?= Emp
window.roller.List ?= List