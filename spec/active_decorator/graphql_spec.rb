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

    describe "define base" do
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
          resolve ->(_, _, _) {
            TestModel.new }
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

    describe 'class base' do
      class Types::BaseObject < GraphQL::Schema::Object; end

      class Types::TestModelTypeClassBase < Types::BaseObject
        field :decoration_method, String, null: false
        field :decoration_method_with_decorate_true, String, null: false
        field :decoration_method_with_decorate_false, String, null: false
      end

      class Types::QueryTypeClassBase < Types::BaseObject
        field :test_model, Types::TestModelTypeClassBase, null: false, resolve: ->(_, _, _) { TestModel.new }
      end

      class TestSchemaClassBase < GraphQL::Schema
        query(Types::QueryTypeClassBase)
      end

      before do
        ActiveDecorator::GraphQL::Config.decorate = true
      end

      specify do
        query = "{ testModel { decorationMethod } }"

        result = TestSchemaClassBase.execute(
          query,
          variables: {},
          context:   {},
        )

        expect(result["data"]["testModel"]["decorationMethod"]).to eq("decoration_method")
      end

      context "set ActiveDecorator::GraphQL::Config.decorate=false" do
        before do
          ActiveDecorator::GraphQL::Config.decorate = false
        end

        specify do
          query = "{ testModel { decorationMethod } }"

          expect {
            TestSchemaClassBase.execute(
              query,
              variables: {},
              context:   {},
            )
          }.to raise_error(RuntimeError)
        end
      end
    end
  end
end
