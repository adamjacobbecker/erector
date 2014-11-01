module Erector
  module Caching
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def cacheable(*args)
        options = args.extract_options!

        @cacheable_opts = {
          static_keys: args,
          dynamic_keys: options[:needs_keys] ? \
            needed_variables & options[:needs_keys] : needed_variables,
          skip_digest: options[:skip_digest]
        }
      end

      def cacheable_opts
        @cacheable_opts
      end
    end

    def cacheable?
      !self.class.cacheable_opts.nil?
    end

    def cache_name
      [].tap do |a|
        self.class.cacheable_opts[:static_keys].each do |x|
          if x.is_a?(Symbol) && respond_to?(x)
            a << send(x)
          else
            a << x
          end
        end

        self.class.cacheable_opts[:dynamic_keys].each do |x|
          a << instance_variable_get(:"@#{x}")
        end
      end.reject(&:nil?)
    end

    def cache_options
      {
        skip_digest: self.class.cacheable_opts[:skip_digest]
      }
    end

    protected
    def _emit(options = {})
      if cacheable? && options[:helpers].try(:respond_to?, :cache)
        options[:helpers].cache cache_name, cache_options do
          super
        end
      else
        super
      end
    end
  end
end
