class WechatController < ApplicationController
    #before_filter :check_wechat_signature

    def server
        check_wechat_signature
        render :text => params[:echostr]
    end

    def post_server
        xml_body = params[:xml]

        @client_user = xml_body["FromUserName"]
        @server_user = xml_body["ToUserName"]
        msgType = xml_body["MsgType"]

        # if (msgType == "text")
        #     if WechatlogStatus.all.count != 0
        #         a_record = Wechatlog.find(WechatlogStatus.first.log_id.to_i + 1)
        #         WechatlogStatus.all.delete_all
        #         @media_id = a_record.logvalue
        #     else
        #         if Wechatlog.all.count != 0
        #             first = Wechatlog.first.id.to_i
        #             last = Wechatlog.last.id.to_i
        #             rand_id = rand(first..last)

        #             q_record = Wechatlog.find(rand_id)
        #             if q_record.logkey != "question"
        #                 q_record = Wechatlog.find(rand_id - 1)
        #             end
        #             WechatlogStatus.create(:log_id => q_record.id)
                    
        #             @media_id = q_record.logvalue   
        #         end
                
        #     end

        # else
        #     @media_id = xml_body["MediaId"]

        #     if Wechatlog.all.count == 0 || Wechatlog.last.logkey == "answer" 
        #         Wechatlog.create(:logkey=>"question",:logvalue=>@media_id)
        #     else
        #         Wechatlog.create(:logkey=>"answer",:logvalue=>@media_id)
        #     end
        # end

        # if (msgType == "text")
        #     text_on_response
        # else
        #     voice_on_reponse (xml_body["MediaId"])
        # end

        case msgType
        when "text"
            text_on_response
        when "voice"
            voice_on_reponse (xml_body["MediaId"])
        when "event"
            event = xml_body["Event"]
            event_key = xml_body["EventKey"]
            event_on_response(event, event_key)
        else
            puts "Others"
        end


    end

    def show_log
        render :json => Wechatlog.all
    end

    def delete_log
        Wechatlog.all.delete_all
        WechatlogStatus.all.delete_all
        render :text => "deleted"
    end

    def show_logstatus
        render :json => WechatlogStatus.all
    end

    # def delete_logstatus
    #     WechatlogStatus.all.delete_all
    #     render :text => "deleted"
    # end

    private 
    def voice_on_reponse (media_id)
        if Wechatlog.all.count == 0 || Wechatlog.last.logkey == "answer" 
            Wechatlog.create(:logkey=>"question",:logvalue=>media_id)
            @text = "问题已上传，请继续上传答案"
        else
            Wechatlog.create(:logkey=>"answer",:logvalue=>media_id)
            @text = "答案已上传"
        end

        render 'wechat/text_template'
    end

    private 
    def text_on_response
        if is_to_get_answer
            puts "This is to get answer"
            @media_id = get_answer

            puts "media_id: " +  @media_id
        else
            puts "This is to get question"
            @media_id = get_rand_question

            puts "media_id: " +  @media_id
        end   
    end

    private 
    def event_on_response (event, event_key)
        if event == "CLICK"
            if event_key == "V1001_Q"
                if is_to_get_answer
                    @media_id = get_answer
                else
                    @media_id = get_rand_question
                end  
                render 'wechat/voice_template'
            elsif event_key == "V1001_D"
                Wechatlog.all.delete_all
                WechatlogStatus.all.delete_all
                @text = "已清空数据库，请重新上传问题和答案"
                render 'wechat/text_template'
            end 
        end
    end

    private 
    def is_to_get_answer
        WechatlogStatus.all.count != 0
    end

    private
    def get_answer
        if WechatlogStatus.all.count != 0
            a_record = Wechatlog.find(WechatlogStatus.first.log_id.to_i + 1)
            WechatlogStatus.all.delete_all

            a_record.logvalue
        end
    end

    private 
    def get_rand_question
        if Wechatlog.all.count != 0
            first = Wechatlog.first.id.to_i
            last = Wechatlog.last.id.to_i
            rand_id = rand(first..last)

            q_record = Wechatlog.find(rand_id)
            if q_record.logkey != "question"
                q_record = Wechatlog.find(rand_id - 1)
            end

            WechatlogStatus.create(:log_id => q_record.id)
            q_record.logvalue
        end
    end

    private
    def check_wechat_signature
        array = ["weixin", params[:timestamp], params[:nonce]].sort
        render :text => "Forbidden", :status => 403 if params[:signature] != Digest::SHA1.hexdigest(array.join)
    end
end
