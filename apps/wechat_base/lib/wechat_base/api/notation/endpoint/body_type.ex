defmodule WechatBase.Api.Notation.Endpoint.BodyType do

  @callback eval(args :: Keyword.t, block :: Macro.t, env :: Macro.Env.t) :: {WechatBase.Api.Endpoint.BodyType.t, WechatBase.Api.Endpoint.BodyType.opts} | no_return

end