defmodule WechatMP.Api do
  use WechatBase.Api.Builder

  namespace :users do
    get :get do
      path "cgi-bin/user/info"
      args do
        required :access_token
        required :openid
        optional :lang
      end
      response WechatMP.Api.Model.User
    end

    post :batch_get do
      path "cgi-bin/user/info/batchget"
      args do
        required :access_token
      end

      body :json do
        field :user_list, required(:array) do
          field :openid, required(:string)
          field :lang, :string
        end
      end

      response WechatMP.Api.Model.UserList
    end

    get :list do
      path "cgi-bin/user/get"
      args do
        required :access_token
        optional :next_openid
      end
      response WechatMP.Api.Model.OpenidConnection
    end

    post :remark do
      path "cgi-bin/user/info/updateremark"
      args do
        required :access_token
      end
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
      args do
        required :access_token
      end
      body :json do
        field :begin_openid, :string
      end
      response WechatMP.Api.Model.BlacklistConnection
    end

    post :ban do
      path "cgi-bin/tags/members/batchblacklist"
      args do
        required :access_token
      end
      body :json do
        field :openid_list, required(list(:string))
      end
      response :ok
    end

    post :unban do
      path "cgi-bin/tags/members/batchunblacklist"
      args do
        required :access_token
      end
      body :json do
        field :openid_list, required(list(:string))
      end
      response :ok
    end
  end

  namespace :contacts, alias: :kf do
    post :add do
      path "customservice/kfaccount/add"
      args do
        required :access_token
      end
      body :json do
        field :kf_account, required(:string)
        field :nickname, required(:string)
        field :password, required(:string) # TODO auto md5
      end
      response :ok
    end

    post :update do
      path "customservice/kfaccount/update"
      args do
        required :access_token
      end
      body :json do
        field :kf_account, required(:string)
        field :nickname, required(:string)
        field :password, required(:string) # TODO auto md5
      end
      response :ok
    end

    post :delete do
      path "customservice/kfaccount/del"
      args do
        required :access_token
      end
      body :json do
        field :kf_account, required(:string)
        field :nickname, required(:string)
        field :password, required(:string) # TODO auto md5
      end
      response :ok
    end

    post :avatar do
      path "customservice/kfaccount/uploadheadimg"
      args do
        required :access_token
        required :kf_account
      end
      body :file
      response :ok
    end

    get :list do
      path "cgi-bin/customservice/getkflist"
      args do
        required :access_token
      end
      response WechatMP.Api.Model.ContactList
    end
  end

  namespace :messages do
    post :custom do
      path "cgi-bin/message/custom/send"
      args do
        required :access_token
      end
      body WechatMP.Api.Model.CustomMessageBody
      response :ok
    end

    post :massive do
      path "cgi-bin/message/mass/sendall"
      args do
        required :access_token
      end
      body WechatMP.Api.Model.MassiveMessageBody
      response WechatMP.Api.Model.MassiveMessage
    end

    post :template do
      path "cgi-bin/message/template/send"
      args do
        required :access_token
      end
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
      args do
        required :access_token
      end
      body :json do
        field :industry_id1, required(:string)
        field :industry_id2, required(:string)
      end
      response :ok
    end

    get :industry do
      path "cgi-bin/template/get_industry"
      required :access_token
      response WechatMP.Api.Model.Industry
    end

    post :add do
      path "cgi-bin/template/api_add_template"
      args do
        required :access_token
      end
      body :json do
        field :template_id_short, required(:string)
      end
      response WechatMP.Api.Model.Template
    end

    get :list do
      path "cgi-bin/template/get_all_private_template"
      args do
        required :access_token
      end
      response WechatMP.Api.Model.TemplateList
    end

    post :delete do
      path "cgi-bin/template/del_private_template"
      args do
        required :access_token
      end
      body :json do
        field :template_id, required(:string)
      end
      response :ok
    end
  end

  namespace :media do

    @desc """
    本接口所上传的图片不占用公众号的素材库中图片数量的5000个的限制。图片仅支持jpg/png格式，大小必须在1MB以下
    """
    post :upload_image do
      path "cgi-bin/media/uploadimg"
      args do
        required :access_token
      end
      body :form do
        field :media, required(:file), limit: 1024 * 1024
      end
      response WechatMP.Api.Model.URL
    end

    @desc """
    群发接口-上传视频素材，获取media_id
    """
    post :upload_video do
      path "cgi-bin/media/uploadvideo"
      args do
        required :access_token
      end
      body :json do
        field :media_id, required(:string)
        field :title, required(:string)
        field :description, required(:string)
      end
      response WechatMP.Api.Model.Media
    end

    @desc """
    群发接口-上传图文消息素材
    """
    post :upload_news do
      path "cgi-bin/media/uploadnews"
      args do
        required :access_token
      end
      body :json do
        field :articles, required(:array) do
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

    @desc """
    创建临时素材
    """
    post :upload do
      path "cgi-bin/media/upload"
      args do
        required :access_token
        required :type
      end
      body :form do
        field :media, required(:file)
      end
      response WechatMP.Api.Model.MediaId
    end

    @desc """
    获取临时素材
    """
    get :get do
      path "cgi-bin/media/get"
      args do
        required :access_token
        required :media_id
      end
      response WechatMP.Api.Model.Media
    end
  end

  namespace :materials do
    @desc """
    新增永久图文素材
    """
    post :add_news do
      path "cgi-bin/material/add_news"
      args do
        required :access_token
      end
      body :json do
        field :articles, required(:array) do
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

    @desc """
    新增永久素材
    """
    post :add do
      path "cgi-bin/material/add_material"
      args do
        required :access_token
        required :type, enum(["image", "voice", "video", "thumb"])
      end
      body :form do
        field :media, required(:file)
        field :title, :string
        field :description, :json #{"title":VIDEO_TITLE, "introduction":INTRODUCTION}
      end
      response WechatMP.Api.Model.MaterialId
    end

    @desc """
    获取永久素材

    注意临时素材无法通过本接口获取
    """
    post :get do
      path "cgi-bin/material/get_material"
      args do
        required :access_token
      end
      body :json do
        field :media, required(:string)
      end
      response WechatMP.Api.Model.Material
    end

    @desc """
    删除永久素材
    """
    post :delete do
      path "cgi-bin/material/del_material"
      args do
        required :access_token
      end
      body :json do
        field :media, required(:string)
      end
      response :ok
    end

    @desc """
    修改永久图文素材
    """
    post :update_news do
      path "cgi-bin/material/update_news"
      args do
        required :access_token
      end
      body :json do
        field :media_id, required(:string)
        field :index, required(:integer)
        field :articles, required(:array) do
          field :title, required(:string)
          field :thumb_media_id, required(:string)
          field :author, required(:string)
          field :digest, required(:string)
          field :show_cover_pic, required(enum(0, 1))
          field :content, required(:string)
          field :content_source_url, required(:string)
        end
      end
      response :ok
    end

    @desc """
    获取素材总数
    """
    get :count do
      path "cgi-bin/material/get_materialcount"
      args do
        required :access_token
      end
      response WechatMP.Api.Model.MaterialCount
    end

    @desc """
    获取素材列表
    """
    post :list do
      path "cgi-bin/material/batchget_material"
      args do
        required :access_token
      end
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
      args do
        required :appid
        required :secret
        required :code
        required :grant_type, "authorization_code"
      end

      response WechatMP.Api.Model.AccessToken
    end

    get :refresh_token do
      path "sns/oauth2/refresh_token"
      args do
        required :appid
        required :grant_type, "refresh_token"
        required :refresh_token
      end

      response WechatMP.Api.Model.AccessToken
    end

    get :user_info do
      path "sns/userinfo"

      args do
        required :access_token
        required :openid
        required :lang, enum("zh_CN", "zh_TW", "en")
      end

      response WechatMP.Api.Model.SNSUser
    end

    get :auth do
      path "sns/auth"

      args do
        required :access_token
        required :openid
      end

      response :ok
    end
  end

  namespace :ticket do
    @desc"""
    请求JsApiTicket和卡券ApiTicket
    """
    get :get do
      path "cgi-bin/ticket/getticket"
      args do
        required :access_token
        required :type, enum("jsapi", "wx_card")
      end
      response WechatMP.Api.Model.Ticket
    end
  end
end
