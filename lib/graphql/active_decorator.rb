require "graphql"
require "rails"
require "active_decorator"
require "graphql/active_decorator/version"

module GraphQL
  class Field
    alias resolve_org resolve
    def resolve(object, arguments, context)
      ::ActiveDecorator::Decorator.instance.decorate(object)
      resolve_org(object, arguments, context)
    end
  end
end
