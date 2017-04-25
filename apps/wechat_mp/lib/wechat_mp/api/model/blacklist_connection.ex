defmodule WechatMP.Api.Model.BlacklistConnection do

  use WechatBase.Api.Model.JsonResponse

  model do
    field :total
    field :count
    field :data do
      array :openid
      field :next_openid
    end
  end
end
