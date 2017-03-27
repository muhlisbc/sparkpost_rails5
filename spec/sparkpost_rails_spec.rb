require "spec_helper"
require "logger"

RSpec.describe SparkpostRails do

  before(:all) do
    suffix    = "email.com.sink.sparkpost.com"
    @sender   = {email: "sender@dev.abylina.com", name: "Sender"}
    @subject  = "This is a subject"
    @rcpt1    = "to1@#{suffix}"
    @rcpt2    = {email: "to2@#{suffix}", name: "User2"}
    @ccs      = (1..3).map { |n| "cc#{n}@#{suffix}" }
    @bccs     = (1..5).map { |n| "bcc#{n}@#{suffix}" }
    @parts    = {
      html: "<p>This is an html body</p>",
      text: "This is a text body"
    }
    @attachment = {name: "test.txt", content: "Dummy text file"}
    @mail     = ActionMailer::Base::Mail::Message.new(
      from:     "#{@sender[:name]} <#{@sender[:email]}>",
      subject:  @subject,
      to:       [@rcpt1, "#{@rcpt2[:name]} <#{@rcpt2[:email]}>"],
      bcc:      @bccs
    )
    @parts.each do |k,v|
      @mail.send("#{k}_part=", v)
    end
    @mail.attachments[@attachment[:name]] = @attachment[:content]
    @custom_payload = {
      options: {
        open_tracking: true
      },
      description: "Send test email",
      content: {
        headers: {
          cc: @ccs.join(","),
          "X-Test" => "Yes"
        }
      }
    }
  end

  context :transform_mail do
    it "should return correct hash" do
      @mail.sparkpost_payload = @custom_payload
      properties = SparkpostRails.transform_mail(@mail)

      # should return correct options
      expect(properties[:options][:open_tracking]).to be_truthy

      # should return not nil description
      expect(properties[:description]).to be_truthy

      # should return nil campaign_id
      expect(properties[:campaign_id]).to be_nil

      # should return correct recipients
      expect(properties[:recipients][0][:address][:email]).to eq(@rcpt1)
      expect(properties[:recipients][0][:address][:name]).to be_nil
      properties[:recipients][1][:address].each do |k, v|
       expect(@rcpt2[k]).to eq(v)
      end

      content = properties[:content]

      # should return correct sender
      content[:from].each do |k, v|
       expect(@sender[k]).to eq(v)
      end

      # should return correct subject
      expect(@subject).to eq(content[:subject])

      # should return correct CCs and BCCs
      ["cc", "bcc"].each do |item|
       expect(instance_variable_get("@#{item}s").join(",")).to eq(content[:headers][item.to_sym])
      end

      # should return correct X-Test custom header
      expect(content[:headers]["X-Test"]).to eq("Yes")

      # should return nil X-Blank custom header
      expect(content[:headers]["X-Blank"]).to be_nil

      # should return correct attachment
      attachment = content[:attachments][0]
      expect(@attachment[:name]).to eq(attachment[:name])
      expect(Base64.encode64(@attachment[:content])).to eq(attachment[:data])
    end
  end

  context "::Mailer.deliver!" do
    it "should success deliver email" do
      @mail.sparkpost_payload = @custom_payload
      response = SparkpostRails::Mailer.new(logger: Logger.new(STDOUT)).deliver!(@mail)
      expect(response["total_accepted_recipients"]).to eq(2)
      expect(response["id"]).to eq(@mail.message_id)
    end
  end
end
