defmodule WechatMP.Api.Model.AccessToken do

  use WechatBase.Api.Model.JsonResponse

  model do
    field :access_token
    field :expires_in
    field :refresh_token
    field :openid
    field :scope
  end
end
