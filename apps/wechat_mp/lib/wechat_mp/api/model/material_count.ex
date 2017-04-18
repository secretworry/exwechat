defmodule WechatMP.Api.Model.MaterialCount do
  
  use WechatBase.Api.Model.JSONResponse

  model do
    field :voice_count
    field :video_count
    field :image_count
    field :news_count
  end
end