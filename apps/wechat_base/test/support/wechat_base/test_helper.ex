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

  defmacro fixture_path(file) do
    do_fixture_path(__CALLER__, file)
  end

  defp do_fixture_path(env, file) do
    prefix = ["test", "fixtures" | Module.split(env.module) |> Enum.map(&Macro.underscore/1)]
    quote do
      Path.join(unquote(prefix) ++ [unquote(file)])
    end
  end
end