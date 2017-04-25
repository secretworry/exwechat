defmodule WechatMP.Api.Model.Ticket do

  use WechatBase.Api.Model.JsonResponse

  model do
    field :ticket
    field :expires_in
  end

end
