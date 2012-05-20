# Bootstrap for Node

This package contains Twitter Bootstrap in a form that can be easily required
from node. This package is particularly useful from Convoy or any other asset
pipeline that can require normal node modules.

# Using Bootstrap for Node with Convoy

Bootstrap is mostly useful client side so you probably want to use it from
within an asset pipeline. This package comes with prebuilt support for
[Convoy](http://github.com/charlesjolley/convoy).

To use Bootstrap, you should add support for LESS to your asset pipeline:

```javascript
var pipeline = convoy({
  'app.css': {
    packager: 'css',
    compilers: {
       '.css': convoy.plugins.CSSCompiler,
       '.less': require('bootstrap-css/packager').LESSCompiler
    }
  }
});
```

Now you can just require the Bootstrap LESS files directly within your own
CSS or LESS source using @import.

**IMPORTANT:** You must always import `variables.less` as well as the main 
bootstrap file. This way you can modify the variables as needed to tune for 
your own site colors, etc.

```css
/* in your main CSS file */
@import "bootstrap-css/css/variables"
@import "bootstrap-css/css/bootstrap"

/* If you want responsive design */
@import "bootstrap-css/css/responsive"
```

Using jQuery plugins is as simple as requiring the plugin in your main source.
Since these are plugins, make sure you require jQuery first and make it
global.

```javascript
$ = require('jquery');
require('bootstrap-css/plugins/alert');
```

# Contributing

Most of the code here comes from 
[Twitter Bootstrap](http://github.com/twitter/bootstrap). You probably want to
go there to contribute.

If you would like to contribute to this package itself, just 
[fork the repo on Github](http://github.com/charlesjolley/bootstrap-css) and
submit a pull request.

To build the package, you will need `jake`. Just run `jake dist` to update and
build the NPM package. This will checkout a copy of bootstrap for you and then
generate  the package content.
