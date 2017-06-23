module ActiveDecorator
  module GraphQL
    module Config
      class << self
        attr_accessor :decorate
        def decorate?
          !!@decorate
        end
      end
    end
    Config.decorate = true
  end
end
