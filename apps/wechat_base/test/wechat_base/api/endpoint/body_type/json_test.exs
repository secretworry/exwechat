defmodule WechatBase.Api.Endpoint.BodyType.JsonTest do

  use WechatBase.Api.Endpoint.BodyType.Case
  alias WechatBase.Api.Endpoint.BodyType.Json
  alias Maxwell.Conn

  test "should embed a valid body" do
    opts = Json.init([
      {:string, "string", %{}, []},
      {:integer, "integer", %{}, []},
      {:float, "float", %{}, []},
      {:object, "object", %{}, [
        {:string, "key", %{}, []},
        {:string, "value", %{}, []}
      ]},
      {{:array, :string}, "array_of_string", %{}, []},
      {{:map, :string}, "map_of_string", %{}, []}])

    body = %{
      "string" => "test",
      "integer" => 42,
      "float" => 4.2,
      "object" => %{
        "key" => "key",
        "value" => "value"
      },
      "array_of_string" => ["a", "b"],
      "map_of_string" => %{
        "key0" => "value0",
        "key1" => "value1"
      }
    }
    {:ok, conn} = Json.embed(Conn.new("http://test.com"), body, opts)
    assert conn.req_body == Poison.encode!(body)
    assert conn.req_headers == %{"content-type" => "application/json"}
  end

  test "should reject a non-map body" do
    opts = Json.init([])
    assert_error Json.embed(Conn.new("http://test.com"), [], opts),
                 {:illegal_body, "Expect a map as body but got %{body}", %{body: []}}
  end

  test "should reject a invalid body" do
    opts = Json.init([
      {:string, "string", %{required?: true}, []}
    ])
    assert_body_errors Json.embed(Conn.new("http://test.com"), %{}, opts),
                       [{"string", {"is required", []}}]
  end
end