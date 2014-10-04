setupEditors = (onInput) ->
	sourceEditor = ace.edit 'source-editor'
	sourceEditor.setTheme 'ace/theme/monokai'
	sourceEditor.getSession().setMode 'ace/mode/javascript'
	sourceEditor.setFontSize 18
	sourceEditor.on 'input', onInput

	outputEditor = ace.edit 'output-editor'
	outputEditor.setTheme 'ace/theme/monokai'
	outputEditor.getSession().setMode 'ace/mode/javascript'
	outputEditor.getSession().setUseWrapMode true
	outputEditor.setReadOnly true
	outputEditor.setFontSize 18

	{ sourceEditor, outputEditor }


onInput = ->
	newSource = roller.obfuscate sourceEditor.getValue()
	outputEditor.setValue newSource


{ sourceEditor, outputEditor } = setupEditors onInput

AjaxUtil.load 'sample1.js', (source) ->
	sourceEditor.setValue source, 1