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
      if need_decorate?
        if object.respond_to?(:object)
          ::ActiveDecorator::Decorator.instance.decorate(object.object)
        else
          ::ActiveDecorator::Decorator.instance.decorate(object)
        end
      end
      resolve_org(object, arguments, context)
    end

    def need_decorate?
      return decorate? unless self.decorate.nil?
      ::ActiveDecorator::GraphQL::Config.decorate?
    end
  end
  Field.own_dictionary[:decorate] = ::GraphQL::Define::InstanceDefinable::AssignAttribute.new(:decorate)
end
