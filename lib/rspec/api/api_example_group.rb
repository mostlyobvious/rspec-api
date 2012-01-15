require "active_support/concern"
require "active_support/core_ext/object/blank"
require "active_support/core_ext/module/delegation"
require "active_support/core_ext/array/extract_options"

module RSpec
  module Api
    module ApiExampleGroup
      extend ActiveSupport::Concern

      module ClassMethods
        class << self
          def define_action(method)
            define_method method do |*args, &block|
              options = args.extract_options!
              options[:method] = method
              options[:path]   = args.first
              newargs = ["#{options[:method].to_s.upcase} #{options[:path]}", options]
              context(*newargs, &block)
            end
          end
        end

        define_action :get
        define_action :head
        define_action :post
        define_action :put
        define_action :patch
        define_action :delete

        def parameter(name, description, options = {})
          parameters.push(options.merge(:name => name.to_s, :description => description))
        end

        def required_parameters(*names)
          names.each do |name|
            param = parameters.find { |param| param[:name] == name.to_s }
            raise "Undefined parameters can not be required." unless param
            param[:required] = true
          end
        end

        def scope_parameters(scope, keys)
          return unless metadata[:parameters]

          keys = parameter_keys if keys == :all
          keys.each do |key|
            param = parameters.detect { |param| param[:name] == key.to_s }
            param[:scope] = scope if param
          end
        end

        def example_request(description, params = {}, &block)
          example(description) do
            response = do_request(params)
            instance_eval block.call(response) if block_given?
          end
        end

        private
        def parameters
          metadata[:parameters] ||= []
          if superclass_metadata && metadata[:parameters].equal?(superclass_metadata[:parameters])
            metadata[:parameters] = Marshal.load(Marshal.dump(superclass_metadata[:parameters]))
          end
          metadata[:parameters]
        end

        def parameter_keys
          parameters.map { |param| param[:name] }
        end
      end

      module InstanceMethods
        delegate :last_response, :response_body, :to => :client

        def client
          raise RuntimeError, "You must inject client dependency"
        end

        def do_request(extra_params = {})
          @extra_params  = extra_params
          params_or_body = nil
          path_or_query  = path

          if method == :get && !query_string.blank?
            path_or_query = path + "?#{query_string}"
          else
            params_or_body = respond_to?(:raw_post) ? raw_post : params
          end

          response = client.send(method, path_or_query, params_or_body)
          yield response if block_given?
          response
        end

        private
        def query_string
          params.to_a.map { |param| param.map { |a| CGI.escape(a.to_s) }.join("=") }.join("&")
        end

        def params
          return unless example.metadata[:parameters]
          example.metadata[:parameters].inject({}) { |hash, param| set_param(hash, param) }.merge(extra_params)
        end

        def method
          example.metadata[:method]
        end

        def path_params
          example.metadata[:path].scan(/:(\w+)/).flatten
        end

        def path
          example.metadata[:path].gsub(/:(\w+)/) { |match| respond_to?($1) ? send($1) : match }
        end

        def in_path?(param)
          path_params.include?(param)
        end

        def extra_params
          return {} if @extra_params.nil?
          @extra_params.inject({}) { |h, (k, v)| h[k.to_s] = v; h }
        end

        def set_param(hash, param)
          key = param[:name]
          return hash if !respond_to?(key) || in_path?(key)

          if param[:scope]
            hash[param[:scope].to_s] ||= {}
            hash[param[:scope].to_s][key] = send(key)
          else
            hash[key] = send(key)
          end
          hash
        end
      end

      included do
        metadata[:type] = :api
      end
    end
  end
end
