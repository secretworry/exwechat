defmodule WechatBase.Api.Endpoint.BodyType.Json.SchemaTest do

  use WechatBase.Api.Endpoint.BodyType.Case

  import WechatBase.Api.Endpoint.BodyType.Json.Schema

  describe "validate!/1" do
    test "should validate valid schema" do
      assert validate!([]) == []
      assert validate!([ {:string, "string", %{}, []} ])
          == [{:string, "string", %{}, []}]
      assert validate!([{{:array, :string}, "array_of_string", %{}, []}])
          == [{{:array, :string}, "array_of_string", %{}, []}]
      assert validate!([{{:map, :string}, "map_of_string", %{}, []}])
          == [{{:map, :string}, "map_of_string", %{}, []}]
      assert validate!([{:object, "object", %{}, [{:string, "string", %{}, []}]}])
          == [{:object, "object", %{}, [{:string, "string", %{}, []}]}]
    end

    test "should reject illegal schema node" do
      assert_raise ArgumentError, "Illegal node, expecting {node_type, identifier, opts, children}, but got {:string} at \"\"", fn->
        validate!([{:string}])
      end
    end

    test "should reject illegal node_type" do
      assert_raise ArgumentError, ~s{Illegal node_type :illegal_type at \".wrong\"}, fn->
        validate!([{:illegal_type, "wrong", %{}, []}])
      end
    end

    test "should reject illegal array node type" do
      assert_raise ArgumentError, ~s{Illegal node_type :illegal_type at ".wrong"}, fn->
        validate!([{{:array, :illegal_type}, "wrong", %{}, []}])
      end
    end

    test "should reject illegal identifier" do
      assert_raise ArgumentError, ~s{Illegal identifier 5 at ""}, fn->
        validate!([{:string, 5, %{}, []}])
      end
    end

    test "should reject primary node with children" do
      assert_raise ArgumentError, ~s|Illegal node, node of primary_type cannot have any child but get [{:string, "string", %{}, []}] at ".string"|, fn->
        validate!([{:string, "string", %{}, [{:string, "string", %{}, []}]}])
      end
    end
  end

  describe "validate_body/2" do
    test "should validate valid body" do
      assert validate_body([], %{}) == :ok
      assert validate_body([{:string, "string", %{}, []}], %{"string" => "key"}) == :ok
      assert validate_body([{:integer, "integer", %{}, []}], %{"integer" => 5}) == :ok
      assert validate_body([{:float, "float", %{}, []}], %{"float" => 5.5}) == :ok
      assert validate_body([{{:array, :string}, "array_of_string", %{}, []}], %{"array_of_string" => ["a"]}) == :ok
      assert validate_body([{{:array, :string}, "array_of_string", %{}, []}], %{"array_of_string" => []}) == :ok
      assert validate_body([{{:map, :string}, "map_of_string", %{}, []}], %{"map_of_string" => %{"key" => "value"}}) == :ok
      assert validate_body([{:object, "object", %{}, [
        {:string, "string", %{}, []},
        {:integer, "integer", %{}, []},
        {:float, "float", %{}, []},
      ]}], %{
        "object" => %{
          "string" => "string",
          "integer" => 5,
          "float" => 5.5
        }
      }) == :ok
    end

    test "should reject value of illegal primary type" do
      assert_body_errors(
        validate_body([{:string, "string", %{}, []}], %{"string" => 5}),
        [{"string", {"should be a string", [value: 5]}}]
      )
      assert_body_errors(
        validate_body([{:integer, "integer", %{}, []}], %{"integer" => "5"}),
        [{"integer", {"should be a integer", [value: "5"]}}]
      )
      assert_body_errors(
        validate_body([{:float, "float", %{}, []}], %{"float" => "5"}),
        [{"float", {"should be a float", [value: "5"]}}]
      )
    end

    test "should reject missing required fields" do
      assert_body_errors(
        validate_body([{:string, "string", %{required?: true}, []}], %{}),
        [{"string", {"is required", []}}]
      )
      assert_body_errors(
        validate_body([{:object, "object", %{required?: true}, []}], %{}),
        [{"object", {"is required", []}}]
      )
    end

    test "should reject illegal composite type" do
      assert_body_errors(
        validate_body([{{:array, :string}, "array", %{}, []}], %{"array" => %{}}),
        [{"array", {"should be a list", [value: %{}]}}]
      )
      assert_body_errors(
        validate_body([{:object, "object", %{}, []}], %{"object" => "object"}),
        [{"object", {"should be a map", [value: "object"]}}]
      )
      assert_body_errors(
        validate_body([{{:map, :object}, "map", %{}, []}], %{"map" => []}),
        [{"map", {"should be a map", [value: []]}}]
      )
    end

    test "should reject illegal children of object" do
      assert_body_errors(
        validate_body([{{:map, :object}, "map", %{}, [{:string, "key", %{required?: true}, []}, {:string, "value", %{required?: true}, []}]}], %{
          "map" => %{
            "entity0" => %{
              "key" => "key"
            },
            "entity1" => %{
              "value" => "value"
            },
            "entity2" => %{
              "key" => 1,
              "value" => "value"
            },
            "entitiy3" => %{
              "key" => "key",
              "value" => 1
            },
            "entity4" => %{
              "key" => "key",
              "value" => "value"
            }
          }
        }),[
          {"map.entity0.value", {"is required", []}},
          {"map.entity1.key", {"is required", []}},
          {"map.entity2.key", {"should be a string", [value: 1]}},
          {"map.entitiy3.value", {"should be a string", [value: 1]}}]
      )
    end

    test "should reject illegal element of array" do
      assert_body_errors(
        validate_body([{{:array, :string}, "array", %{}, []}], %{"array" => ["0", 1, 2]}),
        [{"array[1]", {"should be a string", [value: 1]}},
         {"array[2]", {"should be a string", [value: 2]}}]
      )
    end

    test "should reject value not in given enum args" do
      assert_body_errors(
        validate_body([{:integer, "enum_integer", %{enum: [0, 1]}, []}], %{"enum_integer" => 2}),
        [{"enum_integer", {"should be in %{enum} but got %{value}", [enum: [0, 1], value: 2]}}]
      )
    end
  end
end