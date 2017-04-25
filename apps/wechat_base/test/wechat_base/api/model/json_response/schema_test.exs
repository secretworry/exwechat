defmodule WechatBase.Api.Model.JsonResponse.SchemaTest do

  use ExUnit.Case

  alias WechatBase.Api.Model.JsonResponse.Schema

  describe "convert/3" do
    test "should convert nil" do
      schema = [{:string, nil}, {:integer, nil}, {:float, nil}]
      assert Schema.convert(schema, nil, %{}) == %{}
      assert Schema.convert(schema, %{"string" => nil}, %{}) == %{}
    end

    test "should convert a json" do
      schema = [{:string, nil}, {:integer, nil}, {:float, nil}]
      assert Schema.convert(schema, %{
        "string" => "string",
        "integer" => 5,
        "float" => 5.5
      }, %{}) == %{
        string: "string",
        integer: 5,
        float: 5.5
      }
    end

    test "should convert a nested schema" do
      schema = [{:object, [{:key, nil}, {:value, nil}]}]
      assert Schema.convert(schema, %{
        "object" => %{
          "key" => "key",
          "value" => "value"
        }
      }, %{}) == %{
        object: %{
          key: "key",
          value: "value"
        }
      }
      assert Schema.convert(schema, %{
        "object" => [%{
          "key" => "key1",
          "value" => "value1"
        }, %{
          "key" => "key2",
          "value" => "value2"
        }]
      }, %{}) == %{
        object: [
          %{
            key: "key1",
            value: "value1"
          }, %{
            key: "key2",
            value: "value2"
          }
        ]
      }
    end

    test "should keep value untouched when not specified" do
      schema = [{:object, nil}]
      assert Schema.convert(schema, %{
        "object" => %{
          "key" => "value"
        }
      }, %{}) == %{
        object: %{
          "key" => "value"
        }
      }
    end
  end
end
