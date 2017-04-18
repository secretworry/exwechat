defmodule WechatMP.Api.Model.ContactList do
  @moduledoc false

  use WechatBase.Api.Model.JSONResponse

  model do
    list :kf_list do
      field :kf_account
      field :kf_nick
      field :kf_id
      field :kf_headimgurl
    end
  end
end