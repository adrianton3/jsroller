JSRoller
========

Try the **[demo](http://adrianton3.github.io/jsroller/examples/browser/browser.html)**!

Source code transformation tool that will:

 + straighten out your code
 + eliminate any camelcase/snakecase/rabbitcase related issues
 + get rid of any magic numbers/strings
 + drastically reduce the noise level in the code
 

####Small examples

| Original          | Rolled                        | Header                                              |
| ----------------- | ----------------------------- | --------------------------------------------------- |
| `var a, b, c;`    | `var _____, ______, _______;` |                                                     |
| `function f() {}` | `function _____() {}`         |                                                     |
| `window`          | `___`                         | `var ___ = window;`                                 |
| `globalVar`       | `___[____._];`                | `var ___ = window; var ____ = { _: 'globalVar', };` |
| `var a; a.b;`     | `var _____; _____[_._];`      | `var _ = { _: 'b', };`                              |
| `123`             | `__._;`                       | `var __ = { _: 123, };`                             |