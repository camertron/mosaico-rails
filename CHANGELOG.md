2.0.0
===
* Switched to ActiveStorage as the default image backend. Hence bumped Rails dependency to 5.2.

1.1.1
===
* Fixed asset delivery for custom templates.

1.1.0
===
* Fixed asset delivery for TinyMCE plugins, themes, and skins.
* Fixed Google Plus icon, which was resolving to an invalid URL.

1.0.2
===
* Fix autoload order bug causing NoMethodError when calling `translations_include_tag`.
  This bug was only reproducible a) on first boot, b) when navigating to a Mosaico controller from a controller _outside_ the Mosaico engine, and c) on a completely clean checkout of the repository. I believe this happened because of how Rails autoloads constants. The Mosaico engine defines an `ApplicationController` inside the `Mosaico` module. Most host rails apps will also define an `ApplicationController` at the top-level. It appears rails loads the host app's `ApplicationController` when accessing the outside route, then fails to load the engine's `ApplicationController` when a subsequent request is made to an engine route. The fix was to inherit from `::Mosaico::ApplicationController`, which is an altogether different constant.

1.0.1
===
* Fixed a bug in Mosaico's CSS that was causing a Sass parser error when attempting to precompile assets in the production environment.
  Rails uses Sass as the default CSS compressor, meaning even regular CSS is put through the Sass parser. Mosaico's (minified) CSS contains a media query without any parameters, i.e. @media { ... }, which breaks the Sass parser despite being valid CSS. As a workaround, mosaico-rails now ships with a corrected version of the offending CSS file. There is also a rake task now that can automatically detect and emit fixed CSS when we upgrade to and vendor future versions of Mosaico.

1.0.0
===
* Birthday!
