defmodule WechatMP.Api.Model.TemplateList do

  use WechatBase.Api.Model.JSONResponse

  model do
    field :template_list do
      field :template_id
      field :title
      field :primary_industry
      field :deputy_industry
      field :content
      field :example
    end
  end
end