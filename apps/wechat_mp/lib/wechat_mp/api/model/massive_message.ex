defmodule WechatMP.Api.Model.MassiveMessage do

  use WechatBase.Api.Model.JsonResponse

  model do
    field :errcode
    field :errmsg
    field :msg_id
    field :msg_data_id
  end
end
