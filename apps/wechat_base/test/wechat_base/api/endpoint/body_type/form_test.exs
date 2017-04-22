defmodule WechatBase.Api.Endpoint.BodyType.FormTest do

  use WechatBase.Api.Endpoint.BodyType.Case
  alias WechatBase.Api.Endpoint.BodyType.Form
  alias Maxwell.Conn


  test "should embed a valid body" do
    opts = Form.init([
      {:string, "string", %{}},
      {:integer, "integer", %{}},
      {:float, "float", %{}},
      {:file, "media", %{}}
      ])
    path = fixture_path("test.txt")
    body = %{
      "string" => "test",
      "integer" => 42,
      "float" => 4.2,
      "media" => path
    }
    {:ok, conn} = Form.embed(Conn.new("http://example.com"), body, opts)
    assert conn.req_body
        == {:multipart,
            [{"string", "test"},
             {"integer", 42},
             {"float", 4.2},
             {:file, path,
              {"form-data", [{"name", "media"}, {"filename", "test.txt"}]}, []}]}
  end

  test "should reject a invalid body" do
    opts = Form.init([
      {:string, "string", %{required?: true}}
    ])
    assert_body_errors Form.embed(Conn.new("http://example.com"), %{}, opts),
                       [{"string", {"is required", []}}]
  end
end