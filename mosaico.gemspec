$:.push File.expand_path('../lib', __FILE__)
require 'mosaico/version'

Gem::Specification.new do |s|
  s.name          = 'mosaico'
  s.summary       = 'The Mosaico email editor on Rails.'
  s.description   = s.summary
  s.authors       = ['Cameron Dutro']
  s.email         = ['cameron@lumoslabs.com']
  s.homepage      = 'https://github.com/lumoslabs/mosaico-rails'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files ./spec`.split("\n")
  s.require_paths = ['lib']
  s.version       = Mosaico::VERSION

  s.add_dependency 'rails'
  s.add_dependency 'mini_magick'
  s.add_dependency 'generated-assets'
  s.add_dependency 'css-rewrite'
end
