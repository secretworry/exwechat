defmodule WechatMP.Api.Model.MediaId do

  use WechatBase.Api.Model.JsonResponse

  model do
    field :type
    field :media_id
    field :created_at
  end
end
