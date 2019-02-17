require 'rubygems'
require 'bundler/setup'
require 'rubygems/package_task'

Bundler::GemHelper.install_tasks

task :fix_css do
  # This is gross but necessary. Mosaico includes a CSS media query with an empty list
  # of parameters that causes the sass parser to raise an error during asset precompile.
  # The media query in question, i.e. @media { ... }, isn't actually invalid according
  # to the W3C's CSS validator, but the sass parser is apparently fairly strict about
  # what kinds of queries it accepts. Now, you may be wondering why such an issue would
  # affect the plain 'ol CSS in Mosaico. Well, that happens because by default, Rails
  # uses Sass as the CSS compressor, meaning all CSS code goes through the Sass parser.
  # To mitigate the problem, we spit out "fixed" versions of the CSS and require those
  # in our application.css.
  root = File.expand_path(
    File.join('vendor', 'assets', "mosaico-#{Mosaico::MOSAICO_VERSION}", 'mosaico', 'dist'),
    __dir__
  )

  Dir.glob(File.join(root, '*.min.css')).each do |css_file|
    fixed_content = File.read(css_file).gsub(/@media\s*\{/, "@media all {")
    fixed_file = "#{File.basename(css_file).chomp('.css')}-fixed.css"
    fixed_file = File.join(File.dirname(css_file), fixed_file)
    File.write(fixed_file, fixed_content)
    puts "Wrote #{fixed_file}"
  end


  # For some reason some of the MCE skin files contain several invalid CSS rules,
  # so we have to fix it here to avoid errors during asset precompile.
  files = [
    File.join(root, 'vendor', 'skins', 'gray-flat', 'skin.min.css'),
    File.join(root, 'vendor', 'skins', 'gray-flat', 'skin.ie7.min.css')
  ]

  files.each do |file|
    File.write(file, File.read(file).gsub('color:}', 'color:initial}'))
    puts "Wrote #{file}"
  end
end
