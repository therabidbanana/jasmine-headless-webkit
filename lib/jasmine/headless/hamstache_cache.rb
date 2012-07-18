require 'hogan_assets'
require 'haml'

module Jasmine
  module Headless

    class HamstacheCache < CacheableAction

      class << self
        def cache_type
          "hamstache"
        end
      end

      def action
        template_root = HamstacheTemplate.template_root
        template_root = template_root + '/' unless template_root =~ /\/$/
        template_name = file.split(template_root).last.split('.',2).first

        hamld = Haml::Engine.new(File.read(file), {}).render
        compiled_template = HoganAssets::Hogan.compile(hamld)
        # Only emit the source template if we are using lambdas
        text = '' unless HoganAssets::Config.lambda_support?
        text = <<-TEMPLATE
          this.HoganTemplates || (this.HoganTemplates = {});
          this.HoganTemplates["#{template_name}"] = new Hogan.Template(#{compiled_template}, #{text.inspect}, Hogan, {});
        TEMPLATE
      end
    end
  end
end


