require "graphql"
require "rails"
require "active_decorator"
require "active_decorator/graphql/version"

module GraphQL
  class Field
    alias resolve_org resolve
    def resolve(object, arguments, context)
      ::ActiveDecorator::Decorator.instance.decorate(object)
      resolve_org(object, arguments, context)
    end
  end
end
