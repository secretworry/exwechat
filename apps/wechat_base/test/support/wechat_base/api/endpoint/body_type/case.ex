defmodule WechatBase.Api.Endpoint.BodyType.Case do

  use ExUnit.CaseTemplate

  using do
    quote do
      use WechatBase.Case
      import unquote(__MODULE__)
    end
  end

  def assert_body_errors({:error, {:illegal_body, _, %{errors: errors}}}, expect_errors) do
    assert Enum.sort_by(errors, &elem(&1, 0))
        == Enum.sort_by(expect_errors, &elem(&1, 0))
  end
  def assert_body_errors(error, errors) do
    refute true, "Expect errors #{inspect errors} but got #{error}"
  end
end