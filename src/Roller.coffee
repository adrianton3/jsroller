traverse = (visitor) ->
	call = (element, parent, key, state) ->
		newState = null
		cont = true

		newState = visitor(
			element
			parent
			key
			state
			(_newState) -> newState = _newState
			(_cont) -> cont = _cont
		)
		if cont
			_traverse element, newState
		return


	_traverse = (node, state) ->
		if Array.isArray node
			node.forEach (element, index) ->
				call element, node, index, state
				return
		else if node and typeof node == 'object'
			(Object.keys node).forEach (key) ->
				call node[key], node, key, state
				return

	_traverse


getLevelInfo = (node) ->
	getVarsInDeclaration = (node) ->
		node.declarations.map (declaration) ->
			declaration.id.name

	localVars = new Set
	varIds = []
	memberExpressions = []
	literalEntries = []
	functions = []

	localVarsVisitor = (node, parent, key, state, saveState, cont) ->
		if not node?
			cont false
			return

		if node.type == 'FunctionDeclaration' or node.type == 'FunctionExpression'
			if node.type == 'FunctionDeclaration'
				localVars.add node.id.name
				varIds.push { parent: node, key: 'id', name: node.id.name }
			functions.push node
			cont false
		else if node.type == 'VariableDeclaration'
			varsInDeclaration = getVarsInDeclaration node
			varsInDeclaration.forEach (varInDeclaration) ->
				localVars.add varInDeclaration
				return
		else if key == 'property' and parent.type == 'MemberExpression' and not parent.computed
			memberExpressions.push parent
		else if node.type == 'Literal' and not (parent.type == 'Property' and key == 'key')
			literalEntries.push { parent, key, value: node.raw }
		else if node.type == 'Identifier' and not (parent.type == 'Property' and key == 'key')
			varIds.push { parent, key, name: node.name }

		return


	# if starting node is function add formal parameters and function name
	if node.type == 'FunctionDeclaration' or node.type == 'FunctionExpression'
		# function declaration ids are added in the parent scope
		if node.type == 'FunctionExpression' and node.id?
			localVars.add node.id.name
			varIds.push { parent: node, key: 'id', name: node.id.name }

		node.params.forEach (param, index) ->
			localVars.add param.name
			varIds.push { parent: node.params, key: index, name: param.name }
			return

	# traverse for local vars
	if node.type == 'FunctionDeclaration' or node.type == 'FunctionExpression'
		((traverse localVarsVisitor) node.body)
	else
		((traverse localVarsVisitor) node)

	{
		localVars
		varIds
		memberExpressions
		literalEntries
		functions
	}


buildPropertyObject = (properties) ->
	string = 'var _ = {\n'
	properties.forEach (entry, key) ->
		string += "    #{entry.newName}: '#{key}',\n"
		return
	string += '};'


buildLiteralObject = (literals) ->
	string = 'var __ = {\n'
	literals.forEach (entry, key) ->
		string += "    #{entry.newName}: #{key},\n"
		return
	string += '};'


buildGlobalObject = (globals) ->
	string = 'var ___ = window;\n' +
		'var ____ = {\n'
	globals.forEach (entry, key) ->
		string += "    #{entry.newName}: ___.#{key},\n"
		return
	string += '};'


buildProperty = (objectName, propertyName) ->
	type: 'MemberExpression',
	computed: false,
	object:
		type: 'Identifier',
		name: objectName
	property:
		type: 'Identifier',
		name: propertyName


getReplacer = (objectName, buildString) ->
	map = new Map

	replacer = (name) ->
		if map.has name
			(map.get name).newProperty
		else
			newName = buildString (map.size + 1)
			newProperty = buildProperty objectName, newName
			map.set name, { newName, newProperty }
			newProperty

	[map, replacer]


obfuscate = (source, options = {}) ->
	options.headers ?= true
	options.wrap ?= false
	options.stringBuilderType ?= 'Unary'


	getNewVars = (varsSet, frames, prefix) ->
		map = new Map
		localPrefix = 0
		varsSet.forEach (varName) ->
			frame = frames.find (entry) -> entry.varsMap.has varName
			if frame?
				map.set varName, frame.value.varsMap.get varName
			else
				# get new variable name
				localPrefix++
				map.set varName, buildString (prefix + localPrefix)
			return
		map

	buildString = roller["get#{options.stringBuilderType}Builder"]()
	[properties, replaceProperty] = getReplacer '_', buildString
	[literals, replaceLiteral] = getReplacer '__', buildString
	[globals, replaceGlobal] = getReplacer '___', buildString


	replace = (node, frames) ->
		# retrieve local vars and functions to continue with
		{
			localVars,
			varIds,
			memberExpressions,
			literalEntries,
			functions
		} = getLevelInfo node

		# get mapping
		varsMap = getNewVars localVars, frames, frames.value.prefix

		# add mapping to the stack of frames
		updatedFrames = frames.add {
			varsMap,
			prefix: frames.value.prefix + varsMap.size
		}

		# replace local vars
		varIds.forEach (varId) ->
			variable = varId.parent[varId.key]

			return if (variable.name == 'arguments' or variable.name == 'name') and
				not varsMap.has variable.name

			frame = updatedFrames.find (entry) -> entry.varsMap.has variable.name
			if frame?
				variable.name = frame.value.varsMap.get variable.name
			else if variable.name == 'window'
				variable.name = '___'
			else
				varId.parent[varId.key] = replaceGlobal varId.name
			return

		# replace member properties
		memberExpressions.forEach (memberExpression) ->
			memberExpression.property = replaceProperty memberExpression.property.name
			memberExpression.computed = true
			return

		# replace literals
		literalEntries.forEach (entry) ->
			entry.parent[entry.key] = replaceLiteral entry.value
			return

		# obfuscate the following levels
		functions.forEach (_function) ->
			replace _function, updatedFrames
			return

		return



	tree = esprima.parse source
	replace tree, roller.Emp.add { varsMap: new Map, prefix: 5 }
	newSource = escodegen.generate tree

	if options.headers
		propertyObject = buildPropertyObject properties
		literalsObject = buildLiteralObject literals
		globalsObject = buildGlobalObject globals

		header = ''
		header += "#{propertyObject}\n" if properties.size
		header += "#{literalsObject}\n" if literals.size
		header += "#{globalsObject}\n" if globals.size

		newSource = header + newSource

	if options.wrap
		newSource = "(function () {\n#{newSource}\n})();"

	newSource



window.roller ?= {}
window.roller.obfuscate ?= obfuscate
window.roller.getLevelInfo ?= getLevelInfo