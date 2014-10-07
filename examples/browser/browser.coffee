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


setupGui = (onChange) ->
	chkHeaders = document.getElementById 'chk-headers'
	chkHeaders.addEventListener 'change', ->
		options.headers = @checked
		onChange()
		return

	chkWrap = document.getElementById 'chk-wrap'
	chkWrap.addEventListener 'change', ->
		options.wrap = @checked
		onChange()
		return

	return


onInput = ->
	newSource = roller.obfuscate sourceEditor.getValue(), options
	outputEditor.setValue newSource


onOptionsChange = onInput


options = headers: false, wrap: false
{ sourceEditor, outputEditor } = setupEditors onInput
setupGui onOptionsChange

AjaxUtil.load 'sample1.js', (source) ->
	sourceEditor.setValue source, 1