require "spec_helper"
require "active_model"

RSpec.describe GraphQL::ActiveDecorator do
  describe "::VERSION" do
    it "has a version number" do
      expect(GraphQL::ActiveDecorator::VERSION).not_to be nil
    end
  end

  describe "decoration" do
    class TestModel
      include ActiveModel::Model
    end

    module TestModelDecorator
      def decoration_method
        "decoration_method"
      end
    end

    module Types; end

    Types::TestModelType = GraphQL::ObjectType.define do
      name "TestModel"
      field :decoration_method, !types.String
    end

    Types::QueryType = GraphQL::ObjectType.define do
      name "Query"

      field :test_model, Types::TestModelType do
        resolve ->(_, _, _) { TestModel.new }
      end
    end

    TestSchema = GraphQL::Schema.define do
      query(Types::QueryType)
    end

    specify do
      query = <<~QUERY
      {
        test_model {
          decoration_method
        }
      }
      QUERY

      result = TestSchema.execute(
        query,
        variables: {},
        context:   {},
      )

      expect(result["data"]["test_model"]["decoration_method"]).to eq("decoration_method")
    end
  end
end
