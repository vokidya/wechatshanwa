class WechatController < ApplicationController
    def server
        # check_wechat_signature
        # render :text => params[:echostr]
        #render :text => "get"
    end

    def post
        #binding.pry
        #xml_file.css("//ToUserName")[0].content
        xml = Nokogiri::XML(request.body.read)
        result = xml.css("//MediaId")[0].content
        render :text => result
    end

    # private
    # def check_wechat_signature
    #     array = ["weixin", params[:timestamp], params[:nonce]].sort
    #     render :text => "Forbidden", :status => 403 if params[:signature] != Digest::SHA1.hexdigest(array.join)
    # end
end
