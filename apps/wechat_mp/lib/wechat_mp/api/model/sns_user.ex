defmodule WechatMP.Api.Model.SNSUser do

  use WechatBase.Api.Model.JSONResponse

  model do
    field :openid
    field :nickname
    field :sex, as: :gender
    field :province
    field :city
    field :country
    field :headimgurl
    field :privilege
    field :unionid
  end
end