defmodule WechatMP.Api.Model.TemplateMessage do

  use WechatBase.Api.Model.JsonResponse

  model do
    field :errcode
    field :errmsg
    field :msgid
  end
end
