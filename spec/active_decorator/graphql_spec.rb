require "spec_helper"
require "active_model"

RSpec.describe ActiveDecorator::GraphQL do
  describe "::VERSION" do
    it "has a version number" do
      expect(ActiveDecorator::GraphQL::VERSION).not_to be nil
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
      def decoration_method_with_decorate_true
        "decoration_method_with_decorate_true"
      end
      def decoration_method_with_decorate_false
        "decoration_method_with_decorate_false"
      end
    end

    module Types; end

    Types::TestModelType = GraphQL::ObjectType.define do
      name "TestModel"
      field :decoration_method, !types.String
      field :decoration_method_with_decorate_true, !types.String, decorate: true
      field :decoration_method_with_decorate_false, !types.String, decorate: false
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
      query = "{ test_model { decoration_method } }"

      result = TestSchema.execute(
        query,
        variables: {},
        context:   {},
      )

      expect(result["data"]["test_model"]["decoration_method"]).to eq("decoration_method")
    end

    specify do
      query = "{ test_model { decoration_method_with_decorate_true } }"

      result = TestSchema.execute(
        query,
        variables: {},
        context:   {},
      )

      expect(result["data"]["test_model"]["decoration_method_with_decorate_true"]).to eq("decoration_method_with_decorate_true")
    end

    specify do
      query = "{ test_model { decoration_method_with_decorate_false } }"

      expect {
        TestSchema.execute(
          query,
          variables: {},
          context:   {},
        )
      }.to raise_error(NoMethodError)
    end

    context "set ActiveDecorator::GraphQL::Config.decorate=false" do
      before do
        ActiveDecorator::GraphQL::Config.decorate = false
      end

      specify do
        query = "{ test_model { decoration_method } }"

        expect {
          TestSchema.execute(
            query,
            variables: {},
            context:   {},
          )
        }.to raise_error(NoMethodError)
      end

      specify do
        query = "{ test_model { decoration_method_with_decorate_true } }"

        result = TestSchema.execute(
          query,
          variables: {},
          context:   {},
        )

        expect(result["data"]["test_model"]["decoration_method_with_decorate_true"]).to eq("decoration_method_with_decorate_true")
      end

      specify do
        query = "{ test_model { decoration_method_with_decorate_false } }"

        expect {
          TestSchema.execute(
            query,
            variables: {},
            context:   {},
          )
        }.to raise_error(NoMethodError)
      end
    end
  end
end
