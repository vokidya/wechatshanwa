class WechatController < ApplicationController
    def server
        # check_wechat_signature
        # render :text => params[:echostr]
        #render :text => "get"
    end

    def post_server
        #binding.pry
        #xml_file.css("//ToUserName")[0].content
        xml = Nokogiri::XML(request.body.read)
        @content = xml.css("//MediaId")[0].content
        @client_user = xml.css("//FromUserName")[0].content
        @server_user = xml.css("//ToUserName")[0].content
        #@render :text => result
    end

    # private
    # def check_wechat_signature
    #     array = ["weixin", params[:timestamp], params[:nonce]].sort
    #     render :text => "Forbidden", :status => 403 if params[:signature] != Digest::SHA1.hexdigest(array.join)
    # end
end
