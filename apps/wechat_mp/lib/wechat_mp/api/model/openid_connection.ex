defmodule WechatMP.Api.Model.OpenidConnection do

  use WechatBase.Api.Model.JsonResponse

  model do
    field :total
    field :count
    field :data do
      field :openid
      field :next_openid
    end
  end
end
