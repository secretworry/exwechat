defmodule WechatBase.Api.Notation.Endpoint.ArgsTest do

  use WechatBase.Case


  describe "eval/2" do
    test "should build args" do
      defmodule TestEval do
        alias WechatBase.Api.Notation.Endpoint.Args
        @result Args.eval(quote do
          required :required
          optional :optional
        end, __ENV__)
        def result, do: @result
      end

      assert TestEval.result
          == [%WechatBase.Api.Endpoint.Arg{name: :required, required?: true},
              %WechatBase.Api.Endpoint.Arg{name: :optional, required?: false}]
    end
  end
end