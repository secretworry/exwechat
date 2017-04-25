defmodule WechatBase.Api.Model.JsonResponseTest do

  use WechatBase.Case

  alias Maxwell.Conn

  defmodule SimpleJsonResponse do
    use WechatBase.Api.Model.JsonResponse

    model do
      field :key
      field :nested do
        field :key
      end
      array :array
    end

  end

  describe "__schema__" do
    test "should define a schema" do

      assert SimpleJsonResponse.__schema__()
          == [
            {:key, nil},
            {:nested, [
              {:key, nil}
            ]},
            {:array, nil}
          ]
    end
  end

  describe "parse/2" do
    test "should parse a json response" do
      opts = SimpleJsonResponse.init(nil)
      conn = Conn.new("http://example.com/")
      conn = %{conn | resp_body: %{"key" => "value", "nested" => %{"key" => "value"}, "array" => [1, 2, 3]}}
      assert SimpleJsonResponse.parse(conn, opts)
          == {:ok, %SimpleJsonResponse{
            key: "value",
            nested: %{
              key: "value"
            },
            array: [1, 2, 3]
          }}
    end
  end
end
