defmodule WechatMP.Api.Model.MediaId do

  use WechatBase.Api.Model.JSONResponse

  model do
    field :type
    field :media_id
    field :created_at
  end
end