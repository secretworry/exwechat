defmodule WechatMP.Api.Model.User do

  use WechatBase.Api.Model.JsonResponse

  model do
    field :subscribe
    field :openid
    field :nickname
    field :sex, as: :gender
    field :language
    field :city
    field :province
    field :country
    field :headimgurl
    field :subscribe_time
    field :unionid
    field :remark
    field :groupid
    array :tagidlist
  end
end
