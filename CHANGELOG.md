1.0.1
===
- Fixed a bug in Mosaico's CSS that was causing a Sass parser error when attempting to precompile assets in the production environment.
  Rails uses Sass as the default CSS compressor, meaning even regular CSS is put through the Sass parser. Mosaico's (minified) CSS contains a media query without any parameters, i.e. @media { ... }, which breaks the Sass parser despite being valid CSS. As a workaround, mosaico-rails now ships with a corrected version of the offending CSS file. There is also a rake task now that can automatically detect and emit fixed CSS when we upgrade to and vendor future versions of Mosaico.

1.0.0
===
- Birthday!
