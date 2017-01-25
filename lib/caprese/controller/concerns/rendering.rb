require 'active_support/concern'
require 'caprese/adapter/json_api'

module Caprese
  module Rendering
    extend ActiveSupport::Concern

    # Override render so we can automatically use our adapter and find the appropriate serializer
    # instead of requiring that they be explicity stated
    def render(options = {})
      options[:adapter] = Caprese::Adapter::JsonApi
      options[:meta] = meta unless meta.empty?

      if options[:json].respond_to?(:to_ary)
        if options[:json].first.is_a?(Error)
          options[:each_serializer] ||= Serializer::ErrorSerializer
        elsif options[:json].any?
          options[:each_serializer] ||= serializer_for(options[:json].first)
        end
      else
        if options[:json].is_a?(Error)
          options[:serializer] ||= Serializer::ErrorSerializer
        elsif options[:json].present?
          options[:serializer] ||= serializer_for(options[:json])
        end
      end

      super
    end

    # Allows for meta tags to be added in response document
    #
    # @example
    #   meta[:redirect_url] = ...
    #
    # @return [Hash] the meta tag object
    def meta
      @caprese_meta ||= {}
    end

    private

    # Finds a versioned serializer for a given resource
    #
    # @example
    #   serializer_for(post) => API::V1::PostSerializer
    #
    # @note The reason this method is a duplicate of Caprese::Serializer.serializer_for is
    #   because the latter is only ever called from children of Caprese::Serializer, like those
    #   in the API::V1:: scope. If we tried to use that method instead of this one, we end up
    #   with Caprese::[record.class.name]Serializer instead of the proper versioned serializer
    #
    # @param [ActiveRecord::Base] record the record to find a serializer for
    # @return [Serializer,Nil] the serializer for the given record
    def serializer_for(record)
      version_module("#{record.class.name}Serializer").constantize if Serializer.valid_for_serialization(record)
    end
  end
end
