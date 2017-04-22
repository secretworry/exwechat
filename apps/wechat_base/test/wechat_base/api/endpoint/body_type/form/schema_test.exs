defmodule WechatBase.Api.Endpoint.BodyType.Form.SchemaTest do

  use WechatBase.Api.Endpoint.BodyType.Case

  import WechatBase.Api.Endpoint.BodyType.Form.Schema

  describe "validate!/1" do
    test "should validate valid schema" do
      assert validate!([]) == []
      ~w{file string integer float}a |> Enum.each(fn type ->
        assert validate!([{type, "field", %{}}]) == [{type, "field", %{}}]
      end)
    end

    test "should reject illegal type" do
      assert_raise ArgumentError, "Illegal node type, expecting [:file, :string, :integer, :float] but got illegal_type", fn->
        validate!([{:illegal_type, "field", %{}}])
      end
    end

    test "should reject illegal identifier" do
      assert_raise ArgumentError, ~s{Illegal identifier, expecting a string or atom but got 5}, fn->
        validate!([{:file, 5, %{}}])
      end
    end
  end

  def fixture_path(name) do
    Path.join(~w{test fixtures wechat_base api endpoint body_type form schema} ++ [name])
  end

  describe "validate_body/1" do
    test "should validate valid body" do
      assert validate_body([], %{}) == :ok
      assert validate_body([{:file, "file", %{}}], %{"file" => fixture_path("text.txt")})
      assert validate_body([{:string, "string", %{}}], %{"string" => "test"})
      assert validate_body([{:integer, "integer", %{}}], %{"integer" => 5})
      assert validate_body([{:float, "float", %{}}], %{"float" => 5.5})
      assert validate_body([{:float, "float", %{}}], %{"float" => 5})
    end

    test "should reject value of illegal type" do
      assert_body_errors validate_body([{:string, "string", %{}}], %{"string" => 5}),
                         [{"string", {"should be string", [value: 5]}}]

      assert_body_errors validate_body([{:integer, "integer", %{}}], %{"integer" => "test"}),
                         [{"integer", {"should be integer", [value: "test"]}}]

      assert_body_errors validate_body([{:float, "float", %{}}], %{"float" => "test"}),
                         [{"float", {"should be float", [value: "test"]}}]

      assert_body_errors validate_body([{:file, "file", %{}}], %{"file" => 5}),
                         [{"file", {"should be a path", [value: 5]}}]
    end

    test "should reject a directory for file type" do
      assert_body_errors validate_body([{:file, "file", %{}}], %{"file" => fixture_path("directory")}),
                         [{"file", {"not a file", [path: fixture_path("directory")]}}]
    end

    test "should rejct a non-exist file" do
      assert_body_errors validate_body([{:file, "file", %{}}], %{"file" => fixture_path("not_exist")}),
                         [{"file", {"not exist", [path: fixture_path("not_exist")]}}]
    end

    test "should reject a file larger than limit" do
      %{size: size} = File.stat!(fixture_path("big_file.txt"))
      assert_body_errors validate_body([{:file, "file", %{limit: 1}}], %{"file" => fixture_path("big_file.txt")}),
                         [{"file", {"too big", [size: size, path: fixture_path("big_file.txt")]}}]

    end
  end
end