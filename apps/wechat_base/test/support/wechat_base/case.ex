defmodule WechatBase.Case do

  use ExUnit.CaseTemplate

  using do
    quote do
      import WechatBase.TestHelper
    end
  end
end