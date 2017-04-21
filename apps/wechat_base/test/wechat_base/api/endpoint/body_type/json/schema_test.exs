defmodule WechatBase.Api.Endpoint.BodyType.Json.SchemaTest do
  use ExUnit.Case

  import WechatBase.Api.Endpoint.BodyType.Json.Schema

  describe "validate!/1" do
    test "should validate valid schema" do
      assert validate!([]) == []
      assert validate!([ {:string, "string", %{}} ])
          == [{:string, "string", %{}}]
      assert validate!([{{:array, :string}, "array_of_string", %{}, []}])
          == [{{:array, :string}, "array_of_string", %{}, []}]
      assert validate!([{:object, "object", %{}, [{:string, "string", %{}}]}])
          == [{:object, "object", %{}, [{:string, "string", %{}}]}]
    end

    test "should reject illegal schema node" do
      assert_raise ArgumentError, "Illegal node, expecting {primary_type, identifier, opts} or {compose_type, identifier, opts, children}, but got {:string} at \"\"", fn->
        validate!([{:string}])
      end
    end

    test "should reject illegal node_type" do
      assert_raise ArgumentError, "Illegal node_type, expecting [:string, :integer, :float] but got :illegal_type at \".wrong\"", fn->
        validate!([{:illegal_type, "wrong", %{}}])
      end
    end

    test "should reject illegal array node type" do
      assert_raise ArgumentError, ~s{Illegal node_type :illegal_type at ".wrong"}, fn->
        validate!([{{:array, :illegal_type}, "wrong", %{}, []}])
      end
    end

    test "should reject illegal identifier" do
      assert_raise ArgumentError, ~s{Illegal identifier 5 at ""}, fn->
        validate!([{:string, 5, %{}}])
      end
    end
  end
end