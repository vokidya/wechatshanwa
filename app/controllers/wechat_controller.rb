class WechatController < ApplicationController
    def server
        # array = ["wechat", params[:timestamp], params[:nonce]].sort
        # render :text => "Forbidden", :status => 403 if params[:signature] != Digest::SHA1.hexdigest(array.join)
        check_wechat_signature
        render :text => params[:echostr]
    end

    private
    def check_wechat_signature
        array = ["weixin", params[:timestamp], params[:nonce]].sort
        render :text => "Forbidden", :status => 403 if params[:signature] != Digest::SHA1.hexdigest(array.join)
    end
end
