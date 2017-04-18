defmodule WechatMP.Api.Model.BlacklistConnection do

  use WechatBase.Api.Model.JSONResponse

  model do
    field :total
    field :count
    field :data do
      list :openid
      field :next_openid
    end
  end
end