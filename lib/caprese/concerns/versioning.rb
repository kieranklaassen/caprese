require 'active_support/concern'

module Caprese
  module Versioning
    extend ActiveSupport::Concern

    # Get full namespaced module name of object (class)
    #
    # @example
    #   namespaced_module('OrdersController') => 'API::V1::OrdersController'
    #
    # @param [String] suffix the string to append, hypothetically a module in
    #  this namespace's module space
    # @return [String] the namespaced modulized name of the suffix passed in
    def namespaced_module(suffix = nil)
      mod = (self.is_a?(Class) ? self : self.class).name.deconstantize

      name = suffix || mod
      name = name.prepend("#{mod}::") unless suffix.nil? || (/^#{mod}::\.*/).match(suffix)

      name
    end

    # Get full namespaced path (url)
    #
    # @example
    #   namespaced_path('orders') => 'api/v1/orders'
    #
    # @param [String] suffix the string to append, hypothetically an extension in
    #   this namespace's path space
    # @return [String] the full namespaced path name of the suffix passed in
    def namespaced_path(suffix = nil)
      namespaced_module.downcase.split('::').push(suffix).reject(&:nil?).join('/')
    end

    # Get full namespaced dot path (translations)
    #
    # @example
    #   namespaced_dot_path('orders') => 'api/v1/orders'
    #
    # @param [String] suffix the string to append, hypothetically an extension in
    #   this namespace's dot space
    # @return [String] the full namespaced dot path of the suffix passed in
    def namespaced_dot_path(suffix = nil)
      namespaced_module.downcase.split('::').push(suffix).reject(&:nil?).join('.')
    end

    # Get full namespaced underscore name (routes)
    #
    # @example
    #   namespaced_name('orders') => 'api_v1_orders'
    #
    # @param [String] suffix the string to append, hypothetically a name that
    #  needs to be namespaced
    # @return [String] the namespaced name of the suffix passed in
    def namespaced_name(suffix = nil)
      namespaced_module.downcase.split('::').push(suffix).reject(&:nil?).join('_')
    end

    # Strips string to raw unnamespaced format regardless of input format
    #
    # @param [String] str the string to unversion
    # @return [String] the stripped, unnamespaced name of the string passed in
    def unnamespace(str)
      str
      .remove(namespaced_module(''))
      .remove(namespaced_path(''))
      .remove(namespaced_name(''))
      .remove(namespaced_dot_path(''))
    end

    # Get versioned module name of object (class)
    # @note The difference between namespaced and versioned module names is that if an isolated_namespace
    #   is present, version_module will return a module name without the isolated namespace
    #
    # @example
    #   version_module('OrdersController') => 'API::V1::OrdersController'
    #
    # @param [String] suffix the string to append, hypothetically a module in
    #  this version's module space
    # @return [String] the versioned modulized name of the suffix passed in
    def version_module(suffix = nil)
      name = namespaced_module(suffix)

      name = name.gsub("#{Caprese.config.isolated_namespace}::", '') if Caprese.config.isolated_namespace

      name
    end

    # Get versioned path (url)
    #
    # @example
    #   version_path('orders') => 'api/v1/orders'
    #
    # @param [String] suffix the string to append, hypothetically an extension in
    #   this version's path space
    # @return [String] the versioned path name of the suffix passed in
    def version_path(suffix = nil)
      version_module.downcase.split('::').push(suffix).reject(&:nil?).join('/')
    end

    # Get version dot path (translations)
    #
    # @example
    #   version_dot_path('orders') => 'api/v1/orders'
    #
    # @param [String] suffix the string to append, hypothetically an extension in
    #   this version's dot space
    # @return [String] the versioned dot path of the suffix passed in
    def version_dot_path(suffix = nil)
      version_module.downcase.split('::').push(suffix).reject(&:nil?).join('.')
    end

    # Get versioned underscore name (routes)
    # @note The difference between namespaced and versioned module names is that if an isolated_namespace
    #   is present, version_module will return a module name without the isolated namespace
    #
    # @example
    #   version_name('orders') => 'api_v1_orders'
    #
    # @param [String] suffix the string to append, hypothetically a name that
    #  needs to be versioned
    # @return [String] the versioned name of the suffix passed in
    def version_name(suffix = nil)
      version_module.downcase.split('::').push(suffix).reject(&:nil?).join('_')
    end

    # Strips string to raw unversioned format regardless of input format
    #
    # @param [String] str the string to unversion
    # @return [String] the stripped, unversioned name of the string passed in
    def unversion(str)
      str
      .remove(version_module(''))
      .remove(version_path(''))
      .remove(version_name(''))
      .remove(version_dot_path(''))
    end
  end
end
