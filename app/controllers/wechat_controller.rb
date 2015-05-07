class WechatController < ApplicationController
    #before_filter :check_wechat_signature

    def server
        check_wechat_signature
        render :text => params[:echostr]
    end

    def post_server
        #binding.pry
        #xml_file.css("//ToUserName")[0].content
        check_wechat_signature
        
        xml = Nokogiri::XML(request.body.read)
        @content = xml.css("//MediaId")[0].content
        @client_user = xml.css("//FromUserName")[0].content
        @server_user = xml.css("//ToUserName")[0].content
        #@render :text => result

        Wechatlog.create(:logkey=>"mediaid",:logvalue=>@content)
        Wechatlog.create(:logkey=>"client_user",:logvalue=>@client_user)
        Wechatlog.create(:logkey=>"server_user",:logvalue=>@server_user)
    end

    def show_log
        render :json => Wechatlog.all
    end

    private
    def check_wechat_signature
        Wechatlog.create(:logkey=>"check",:logvalue=> DateTime.now)
        array = ["weixin", params[:timestamp], params[:nonce]].sort
        render :text => "Forbidden", :status => 403 if params[:signature] != Digest::SHA1.hexdigest(array.join)
    end
end
