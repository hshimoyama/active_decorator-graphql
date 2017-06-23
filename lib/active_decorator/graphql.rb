require "graphql"
require "rails"
require "active_decorator"
require "active_decorator/graphql/version"
require "active_decorator/graphql/config"

module GraphQL
  class Field
    attr_accessor :decorate
    def decorate?
      !!@decorate
    end

    alias resolve_org resolve
    def resolve(object, arguments, context)
      ::ActiveDecorator::Decorator.instance.decorate(object) if need_decorate?
      resolve_org(object, arguments, context)
    end

    def need_decorate?
      return decorate? unless self.decorate.nil?
      ::ActiveDecorator::GraphQL::Config.decorate?
    end
  end
  Field.own_dictionary[:decorate] = ::GraphQL::Define::InstanceDefinable::AssignAttribute.new(:decorate)
end
