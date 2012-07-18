require 'tilt/template'
require 'haml'

module Jasmine::Headless
  class HamstacheTemplate < Tilt::Template
    include Jasmine::Headless::FileChecker

    class << self
      def template_root=(root)
        @template_root = root
      end
      def template_root
        @template_root || "app/views/"
      end
    end

    self.default_mime_type = 'application/javascript'

    def prepare; end

    # def evaluate(scope, locals, &block)
      # text = if scope.pathname.extname == '.hamstache'
        # raise "Unable to complile #{scope.pathname} because haml is not available. Did you add the haml gem?" unless HoganAssets::Config.haml_available?
        # Haml::Engine.new(data, @options).render
      # else
        # data
      # end

      # compiled_template = Hogan.compile(text)
      # template_name = scope.logical_path.inspect

      # # Only emit the source template if we are using lambdas
      # text = '' unless HoganAssets::Config.lambda_support?
      # text = <<-TEMPLATE
        # this.HoganTemplates || (this.HoganTemplates = {});
        # this.HoganTemplates[#{template_name}] = new Hogan.Template(#{compiled_template}, #{text.inspect}, Hogan, {});
      # TEMPLATE
    # end
    def evaluate(scope, locals, &block)
      if bad_format?(file)
        alert_bad_format(file)
        return ''
      end
      begin
        cache = Jasmine::Headless::HamstacheCache.new(file)
        source = cache.handle
        if cache.cached?
          %{<script type="text/javascript" src="#{cache.cache_file}"></script>
            <script type="text/javascript">window.CSTF['#{File.split(cache.cache_file).last}'] = '#{file}';</script>}
        else
          %{<script type="text/javascript">#{source}</script>}
        end
      rescue StandardError => e
        puts "[%s] Error in compiling file: %s" % [ 'hamstache'.color(:red), file.color(:yellow) ]
        raise e
      end
    end
  end
end
