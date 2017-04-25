defmodule WechatMP.Api.Model.Template do

  use WechatBase.Api.Model.JsonResponse

  model do
    field :errcode
    field :errmsg
    field :template_id
  end
end
