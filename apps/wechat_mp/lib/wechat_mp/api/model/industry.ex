defmodule Wechat.Api.Model.Industry do

  use WechatBase.Api.Model.JsonResponse

  model do
    field :primary_industry do
      field :first_class
      field :second_class
    end
    field :secondary_industry do
      field :first_class
      field :second_class
    end
  end
end
