defmodule WechatBase.Api.Notation.Endpoint.BodyType.JsonTest do

  use WechatBase.Case

  alias WechatBase.Api.Endpoint.BodyType.Json

  test "should define a empty schema" do
    defmodule EmptySchema do
      use WechatBase.Api.Notation.Endpoint.BodyType.JsonTest.Definition
      eval :empty do
      end
    end

    assert EmptySchema.json(:empty) == {Json, []}
  end

  test "should define a plain schema" do
    defmodule PlainSchema do
      use WechatBase.Api.Notation.Endpoint.BodyType.JsonTest.Definition
      eval :test do
        field :string_field, required(:string)
        field :integer_field, required(:integer)
        field :float_field, :float
        field :number_enum, enum(1, 2)
        field :required_enum, required(enum(1, 2))
      end
    end

    assert PlainSchema.json(:test) == {Json, [
      {:string, :string_field, %{required?: true}, []},
      {:integer, :integer_field, %{required?: true}, []},
      {:float, :float_field, %{}, []},
      {:integer, :number_enum, %{enum: [1, 2]}, []},
      {:integer, :required_enum, %{required?: true, enum: [1, 2]}, []}
    ]}
  end

  test "should define a nested schema" do
    defmodule NestedSchema do
      use WechatBase.Api.Notation.Endpoint.BodyType.JsonTest.Definition
      eval :nested do
        field :object_field do
          field :key, :string
          field :value, :string
        end
        field :array_field, required(:array) do
          field :key, :string
          field :value, :string
        end
      end
    end

    assert NestedSchema.json(:nested) == {Json, [
      {:object, :object_field, %{}, [
        {:string, :key, %{}, []},
        {:string, :value, %{}, []}
      ]},
      {{:array, :object}, :array_field, %{required?: true}, [
        {:string, :key, %{}, []},
        {:string, :value, %{}, []}
      ]}
    ]}
  end
end