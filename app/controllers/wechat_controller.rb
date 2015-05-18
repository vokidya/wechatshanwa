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

    def show_page
        token = get_token

        @token = token
        jsapi_ticket = get_ticket (token)
        noncestr = [*'a'..'z',*'0'..'9',*'A'..'Z'].sample(15).join
        timestamp = Time.now.to_i.to_s
        url = "http://cc60e35d.ngrok.io/wechat/page"

        string1 = "jsapi_ticket=#{jsapi_ticket}&noncestr=#{noncestr}&timestamp=#{timestamp}&url=#{url}"
        @signature = Digest::SHA1.hexdigest(string1)
        @jsapi_ticket = jsapi_ticket
        @noncestr = noncestr
        @timestamp = timestamp
    end

    private 
    def get_token
        token_config = WechatConfig.find_by(:key_name=>"token")

        if token_config.blank? 
            token_config = WechatConfig.create(:key_name=>"token",:key_value=>"",:key_expired_time=>"0")
        end

        if token_config.key_expired_time.to_i > Time.now.to_i
            token = token_config.key_value
        else
            appid = "wx5d6dd39846be546a"
            secret = "c369efa33a2446a7af5fad77c80a4566"
            token_url = "https://api.weixin.qq.com/cgi-bin/token?grant_type=client_credential&appid=#{appid}&secret=#{secret}"
            
            token_result = HTTParty.get token_url
            token = token_result.parsed_response["access_token"]
            token_expired_time = Time.now.to_i + 7200

            token_config.key_value = token
            token_config.key_expired_time = token_expired_time
            token_config.save
        end
    end

    private 
    def get_ticket (token)
        ticket_config = WechatConfig.find_by(:key_name=>"ticket")

        if ticket_config.blank? 
            ticket_config = WechatConfig.create(:key_name=>"ticket",:key_value=>"",:key_expired_time=>"0")
        end

        if ticket_config.key_expired_time.to_i > Time.now.to_i
            ticket = ticket_config.key_value
        else
            ticket_url = "https://api.weixin.qq.com/cgi-bin/ticket/getticket?access_token=#{token}&type=jsapi"
            ticket_result = HTTParty.get ticket_url
            ticket = ticket_result.parsed_response["ticket"]
            ticket_expired_time = Time.now.to_i + 7200

            ticket_config.key_value = ticket
            ticket_config.key_expired_time = ticket_expired_time
            ticket_config.save
        end
    end

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
