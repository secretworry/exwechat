defmodule WechatBase.TestHelper do

  import ExUnit.Assertions

  def assert_error({:error, {error, message, args}}, {expect_error, expect_message, expect_args}) do
    assert error == expect_error
    assert message == expect_message
    Enum.each(expect_args, fn
      {key, value} ->
        assert Map.get(args, key) == value
    end)
  end

  def assert_error(response, error) do
    refute true, "expect error #{inspect error} but got #{inspect response}"
  end
end