defmodule WechatMP.Api.Model.UserList do

  use WechatBase.Api.Model.JSONResponse

  model do
    field :total
    field :count
    field :data do
      array :openid
      field :next_openid
    end
  end
end