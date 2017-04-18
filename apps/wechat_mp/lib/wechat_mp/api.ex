defmodule WechatMP.Api do
  use WechatBase.Api.Builder

  namespace :users do
    get :get do
      path "cgi-bin/user/info"
      arg :access_token, required(:string)
      arg :openid, required(:string)
      arg :lang, :string
      response WechatMP.Api.Model.User
    end

    post :batch_get do
      path "cgi-bin/user/info/batchget"
      arg :access_token, required(:string)

      body :json do
        array :user_list do
          field :openid, required(:string)
          field :lang, :string
        end
      end

      response WechatMP.Api.Model.UserList
    end

    get :list do
      path "cgi-bin/user/get"
      arg :access_token, required(:string)
      arg :next_openid, :string
      response WechatMP.Api.Model.OpenidConnection
    end

    post :remark do
      path "cgi-bin/user/info/updateremark"
      arg :access_token, required(:string)
      body :json do
        field :openid, required(:string)
        field :remark, required(:string)
      end
      response :ok
    end
  end

  namespace :members do
    post :blacklist do
      path "cgi-bin/tags/members/getblacklist"
      arg :access_token, required(:string)
      body :json do
        field :begin_openid, :string
      end
      response WechatMP.Api.Model.BlacklistConnection
    end

    post :ban do
      path "cgi-bin/tags/members/batchblacklist"
      arg :access_token, required(:string)
      body :json do
        field :openid_list, required(list(:string))
      end
      response :ok
    end

    post :unban do
      path "cgi-bin/tags/members/batchunblacklist"
      arg :access_token, required(:string)
      body :json do
        field :openid_list, required(list(:string))
      end
      response :ok
    end
  end

  namespace :contacts, alias: :kf do
    post :add do
      path "customservice/kfaccount/add"
      arg :access_token, required(:string)
      body :json do
        field :kf_account, required(:string)
        field :nickname, required(:string)
        field :password, required(:string) # TODO auto md5
      end
      response :ok
    end

    post :update do
      path "customservice/kfaccount/update"
      arg :access_token, required(:string)
      body :json do
        field :kf_account, required(:string)
        field :nickname, required(:string)
        field :password, required(:string) # TODO auto md5
      end
      response :ok
    end

    post :delete do
      path "customservice/kfaccount/del"
      arg :access_token, required(:string)
      body :json do
        field :kf_account, required(:string)
        field :nickname, required(:string)
        field :password, required(:string) # TODO auto md5
      end
      response :ok
    end

    post :avatar do
      path "customservice/kfaccount/uploadheadimg"
      arg :access_token, required(:string)
      arg :kf_account, required(:string)
      body :file
      response :ok
    end

    get :list do
      path "cgi-bin/customservice/getkflist"
      arg :access_token, required(:string)
      response WechatMP.Api.Model.ContactList
    end
  end

  namespace :messages do
    post :custom do
      path "cgi-bin/message/custom/send"
      arg :access_token, required(:string)
      body WechatMP.Api.Model.CustomMessageBody
      response :ok
    end

    post :massive do
      path "cgi-bin/message/mass/sendall"
      arg :access_token, required(:string)
      body WechatMP.Api.Model.MassiveMessageBody
      response WechatMP.Api.Model.MassiveMessage
    end

    post :template do
      path "cgi-bin/message/template/send"
      arg :access_token, required(:string)
      body :json do
        field :touser, required(:string)
        field :template_id, required(:string)
        field :url, required(:string)
        field :miniprogram do
          field :appid, required(:string)
          field :pagepath, required(:string)
        end
        field :data, required(:map) do
          field :value, required(:string)
          field :color, required(:string)
        end
      end
      response WechatMP.Api.Model.TemplateMessage
    end
  end

  namespace :templates do
    post :set_industry do
      path "cgi-bin/template/api_set_industry"
      arg :access_token, required(:string)
      body :json do
        field :industry_id1, required(:string)
        field :industry_id2, required(:string)
      end
      response :ok
    end

    get :industry do
      path "cgi-bin/template/get_industry"
      arg :access_token, required(:string)
      response WechatMP.Api.Model.Industry
    end

    post :add do
      path "cgi-bin/template/api_add_template"
      arg :access_token, required(:string)
      body :json do
        field :template_id_short, required(:string)
      end
      response WechatMP.Api.Model.Template
    end

    get :list do
      path "cgi-bin/template/get_all_private_template"
      arg :access_token, required(:string)
      response WechatMP.Api.Model.TemplateList
    end

    post :delete do
      path "cgi-bin/template/del_private_template"
      arg :access_token, required(:string)
      body :json do
        field :template_id, required(:string)
      end
      resposne :ok
    end
  end

  namespace :media do

    @doc """
    本接口所上传的图片不占用公众号的素材库中图片数量的5000个的限制。图片仅支持jpg/png格式，大小必须在1MB以下
    """
    post :upload_image do
      path "cgi-bin/media/uploadimg"
      arg :access_token, required(:string)
      body :form do
        file :media, limit: 1024 * 1024
      end
      response WechatMP.Api.Model.URL
    end

    post :upload_video do
      path "cgi-bin/media/uploadvideo"
      arg :access_token, required(:string)
      body :json do
        field :media_id, required(:string)
        field :title, required(:string)
        field :description, required(:description)
      end
      response WechatMP.Api.Model.Media
    end

    @doc """
      Upload news before sending to users
      
      source: https://mp.weixin.qq.com/wiki?t=resource/res_main&id=mp1455784140&token=&lang=zh_CN
    """
    post :upload_news do
      path "cgi-bin/media/uploadnews"
      arg :access_token, required(:string)
      body :json do
        field :articles, required(:list) do
          field :thumb_media_id, required(:string)
          field :author, :string
          field :title, required(:string)
          field :content_source_url, :string
          field :content, required(:string)
          field :digest, :string
          field :show_cover_pic, :string
        end
      end
      response WechatMP.Api.Model.Media
    end

    post :upload do
      path "cgi-bin/media/upload"
      arg :access_token, required(:string)
      arg :type, required(:string)
      body :form do
        field :media, require(:file)
      end
      response WechatMP.Api.Model.MediaId
    end

    get :get do
      path "cgi-bin/media/get"
      arg :access_token, required(:string)
      arg :media_id, required(:string)
      response WechatMP.Api.Model.Media
    end
  end

  namespace :materials do
    post :add_news do
      path "cgi-bin/material/add_news"
      arg :access_token, required(:string)
      body :json do
        field :articles, required(:list) do
          field :title, required(:string)
          field :thumb_media_id, required(:string)
          field :author, required(:string)
          field :digest, required(:string)
          field :show_cover_pic, required(enum([0, 1]))
          field :content, required(:string)
          field :content_source_url, required(:string)
        end
      end
      response WechatMP.Api.Model.MediaId
    end

    post :add do
      path "cgi-bin/material/add_material"
      arg :access_token, required(:string)
      arg :type, required(:string)
      body :form do
        field :media, required(:file)
        field :title, :string
        field :description, :json
      end
      response WechatMP.Api.Model.MaterialId
    end

    post :get do
      path "cgi-bin/material/get_material"
      arg :access_token, required(:string)
      body :json do
        field :media, required(:string)
      end
      response WechatMP.Api.Model.Material
    end

    post :delete do
      path "cgi-bin/material/del_material"
      arg :access_token, required(:string)
      body :json do
        field :media, required(:string)
      end
      response :ok
    end

    post :update_news do
      path "cgi-bin/material/update_news"
      arg :access_token, required(:string)
      body :json do
        field :media_id, required(:string)
        field :index, required(:integer)
        field :articles do
          field :title, required(:string)
          field :thumb_media_id, required(:string)
          field :author, required(:string)
          field :digest, required(:string)
          field :show_cover_pic, required(enum([0, 1]))
          field :content, required(:string)
          field :content_source_url, required(:string)
        end
      end
      response :ok
    end

    get :count do
      path "cgi-bin/material/get_materialcount"
      arg :access_token, required(:string)
      response WechatMP.Api.Model.MaterialCount
    end

    post :list do
      path "cgi-bin/material/batchget_material"
      arg :access_token, required(:string)
      body :json do
        field :type, required(:string)
        field :offset, required(:integer)
        field :count, required(:integer) # between 1..20
      end

      response WechatMP.Api.Model.MaterialConnection
    end
  end


  namespace :sns do
    get :access_token do
      path "sns/oauth2/access_token"
      arg :appid, required(:string)
      arg :secret, required(:string)
      arg :code, required(:string)
      arg :grant_type, required(:string) # should be "authorization_code"

      response WechatMP.Api.Model.AccessToken
    end

    get :refresh_token do
      path "sns/oauth2/refresh_token"
      arg :appid, required(:string)
      arg :grant_type, required(:string) # should be "refresh_token"
      arg :refresh_token, required(:string)

      response WechatMP.Api.Model.AccessToken
    end

    get :user_info do
      path "sns/userinfo"
      arg :access_token, required(:string) # user access token
      arg :openid, required(:string)
      arg :lang, required(enum(["zh_CN", "zh_TW", "en"]))

      response WechatMP.Api.Model.SNSUser
    end

    get :auth do
      path "sns/auth"
      arg :access_token, required(:string)
      arg :openid, required(:string)

      response :ok
    end
  end

  namespace :ticket do
    get :get do
      path "cgi-bin/ticket/getticket"
      arg :access_token, required(:string)
      arg :type, required(enum(["jsapi", "wx_card"]))
      resposne WechatMP.Api.Model.Ticket
    end
  end
end
