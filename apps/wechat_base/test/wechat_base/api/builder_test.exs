defmodule WechatBase.Api.BuilderTest do

  use WechatBase.Case

  defmodule DumbModel do
    @behaviour WechatBase.Api.Endpoint.ResponseType

    def init(opts), do: opts

    def parse(conn, _opts) do
      conn.resp_body
    end
  end

  defmodule ExampleApi do
    use WechatBase.Api.Builder

    namespace :test do
      get :get do
        path "test/get"
        args do
          required :access_token
          required :openid
          optional :lang
        end
        response DumbModel
      end

      post :post do
        path "test/post"
        args do
          required :access_token
        end

        body :json do
          field :body, required(:object) do
            field :key, required(:string)
            field :value, required(:string)
          end
        end
        response DumbModel
      end
    end
  end

  describe "__exwechat_endpoint__/1" do

    test "should define endpoints" do
      assert ExampleApi.__exwechat_endpoint__("test.get")
          == %WechatBase.Api.Endpoint{
              args: [
                %WechatBase.Api.Endpoint.Arg{name: :access_token, required?: true, validator: nil},
                %WechatBase.Api.Endpoint.Arg{name: :openid, required?: true, validator: nil},
                %WechatBase.Api.Endpoint.Arg{name: :lang, required?: false, validator: nil}],
              body_type: nil,
              method: :get,
              path: "test/get",
              response_type: {WechatBase.Api.BuilderTest.DumbModel, []}}
      assert ExampleApi.__exwechat_endpoint__("test.post")
          == %WechatBase.Api.Endpoint{
              args: [
                %WechatBase.Api.Endpoint.Arg{name: :access_token, required?: true, validator: nil}],
              body_type: {
                WechatBase.Api.Endpoint.BodyType.Json,
                [{:object, :body, %{required?: true}, [
                  {:string, :key, %{required?: true}, []},
                  {:string, :value, %{required?: true}, []}]}]},
              method: :post,
              path: "test/post",
              response_type: {WechatBase.Api.BuilderTest.DumbModel, []}}
    end
  end
end