defmodule WechatBase.Api.Endpoint.BodyType.FileTest do

  use WechatBase.Api.Endpoint.BodyType.Case
  alias WechatBase.Api.Endpoint.BodyType.File
  alias Maxwell.Conn

  test "should embed a valid body" do
    opts = File.init(nil)

    path = fixture_path("test.txt")
    {:ok, conn} = File.embed(Conn.new("http://example.com"), path, opts)
    assert conn.req_body
        == {:file, path}
  end

  test "should reject a non-exist body" do
    opts = File.init(nil)
    path = fixture_path("not_exist")
    assert_body_errors File.embed(Conn.new("http://example.com"), path, opts),
                       [{"", {"not exist", [path: path]}}]
  end

  test "should reject non-string body" do
    opts = File.init(nil)
    path = 5
    assert File.embed(Conn.new("http://example.com"), path, opts)
        == {:error, {:illegal_body, "Expecting a path as body but got %{body}", %{body: path}}}
  end
end