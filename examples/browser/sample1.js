function g() {}

function f(cond) {
	if (cond) {
		function g() {}
	}
	g();
}