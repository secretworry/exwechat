defmodule WechatMP.Api.Model.Ticket do

  use WechatBase.Api.Model.JSONResponse

  model do
    field :ticket
    field :expires_in
  end

end