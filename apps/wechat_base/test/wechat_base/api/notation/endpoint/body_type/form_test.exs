defmodule WechatBase.Api.Notation.Endpoint.BodyType.FormTest do

  use WechatBase.Case

  alias WechatBase.Api.Endpoint.BodyType.Form

  test "should define a empty schema" do
    defmodule EmptySchema do
      use WechatBase.Api.Notation.Endpoint.BodyType.FormTest.Definition
      eval :empty do
      end
    end

    assert EmptySchema.form(:empty) == {Form, []}
  end

  test "should define a valid schema" do
    defmodule ValidSchema do
      use WechatBase.Api.Notation.Endpoint.BodyType.FormTest.Definition
      eval :valid do
        field :string_field, :string
        field :integer_field, :integer
        field :float_field, :float
        field :file_field, :file
        field :required_field, required(:string)
        field :integer_enum, enum(1, 2)
        field :required_enum, required(enum(1, 2))
      end
    end

    assert ValidSchema.form(:valid) == {Form, [
      {:string, :string_field, %{}},
      {:integer, :integer_field, %{}},
      {:float, :float_field, %{}},
      {:file, :file_field, %{}},
      {:string, :required_field, %{required?: true}},
      {:integer, :integer_enum, %{enum: [1, 2]}},
      {:integer, :required_enum, %{enum: [1, 2], required?: true}}
    ]}
  end
end