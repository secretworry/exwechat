defmodule WechatBase.Api.EndpointTest do
  use ExUnit.Case

  alias WechatBase.Api.Endpoint
  alias WechatBase.Error

  defp respond(:json, respond) do
    fn _method, conn ->
      {:ok, %{conn | state: :sent, status: 200, resp_headers: %{"content-type" => "application/json"}, resp_body: Poison.encode!(respond)}}
    end
  end

  defp respond(:error, reason) do
    fn _method, conn ->
      {:error, reason, %{conn | state: :error}}
    end
  end

  defp assert_error({:error, {error, message, args}}, {expect_error, expect_message, expect_args}) do
    assert error == expect_error
    assert message == expect_message
    Enum.each(expect_args, fn
      {key, value} ->
        assert Map.get(args, key) == value
    end)
  end

  defp assert_error(response, error) do
    refute true, "expect error #{inspect error} but got #{inspect response}"
  end

  @base_uri "https://api.weixin.qq.com/"

  describe "call/5" do
    test "should reject with :wechat_error for wechat error response" do
      endpoint = %Endpoint{method: :get, path: "test", args: %{}, response_type: {Endpoint.DumbResponseType, nil}}
      assert_error(Endpoint.call(endpoint, @base_uri, %{}, nil, %{request_call: respond(:json, %{"errcode" => 40000, "errmsg" => "test error"})}),
          {:wechat_error, "Wechat Error(%{errcode}): %{errmsg}", %{errcode: 40000, errmsg: "test error"}})
    end

    test "should reject with :request_error for illegal response" do
      endpoint = %Endpoint{method: :get, path: "test", args: %{}, response_type: {Endpoint.DumbResponseType, nil}}
      assert_error(Endpoint.call(endpoint, @base_uri, %{}, nil, %{request_call: respond(:error, :timeout)}),
              {:request_error, "Send request error", %{reason: :timeout}})
    end

    test "should reject with :illegal_args for illegal args" do
      required_args = %Endpoint.Arg{required?: true}
      endpoint = %Endpoint{method: :get, path: "test", args: %{"key0" => required_args, "key1" => required_args}, response_type: {Endpoint.DumbResponseType, nil}}
      assert_error(Endpoint.call(endpoint, @base_uri, %{}, nil, %{request_call: respond(:error, :timeout)}),
        {:illegal_args, "Illegal args", %{errors: [{"key1", {"can't be blank", []}}, {"key0", {"can't be blank", []}}]}}
      )
    end

    test "should get expected response" do
      endpoint = %Endpoint{method: :get, path: "test", args: %{}, response_type: {Endpoint.DumbResponseType, nil}}
      assert Endpoint.call(endpoint, @base_uri, %{}, nil, %{request_call: respond(:json, %{errcode: 0, errmsg: "success"})})
          == {:ok, %{"errcode" => 0, "errmsg" => "success"}}
    end

    test "should reject with body type error" do
      endpoint = %Endpoint{method: :post, path: "test", args: %{}, body_type: {Endpoint.DumbBodyType, {:error, Error.new(:illegal_body, "Illegal body")}}, response_type: {Endpoint.DumbResponseType, nil}}
      assert_error(Endpoint.call(endpoint, @base_uri, %{}, nil, %{request_call: respond(:json, %{errcode: 0, errmsg: "success"})}),
        {:illegal_body, "Illegal body", %{}}
      )
    end
  end
end