require "base64"
require "action_mailer"
require "simple_spark"

module SparkpostRails

  # SparkpostRails::Mailer is an ActionMailer provider for sending mail through Sparkpost.
  class Mailer

    def initialize(config={})
      @sp_client = SimpleSpark::Client.new(config)
    end

    def deliver!(mail)
      properties  = SparkpostRails.transform_mail(mail)
      response    = @sp_client.transmissions.create(properties)
      mail.message_id = response["id"]
      response
    end
  end

  module_function

  # Transform Mail::Message object to Hash that will be send as request payload
  #
  # @param [Mail::Message] mail
  #
  # @return [Hash]
  def transform_mail(mail)
    content   = {}
    sp_object = {}

    sp_object[:recipients]  = mail[:to].address_list.addresses.map { |recipient| {address: fetch_email_and_name(recipient)} } if mail.to
    sp_object[:return_path] = mail[:return_path].address_list.addresses[0].raw if mail.return_path
    content[:from]          = fetch_email_and_name(mail[:from].address_list.addresses[0]) if mail.from && mail.from[0]
    content[:subject]       = mail.subject if mail.subject
    content[:reply_to]      = mail[:reply_to].address_list.addresses[0].raw if mail.reply_to && mail.reply_to[0]
    content[:attachments]   = transform_attachments(mail.attachments) if !mail.attachments.empty?

    ["html", "text"].each do |part|
      mail_part = mail.send("#{part}_part")
      content[part] = mail_part.decoded if mail_part
    end

    [:cc, :bcc].each do |rcpt_type|
      content[:headers] ||= {}
      rcpt_type_val = mail.send(rcpt_type)
      content[:headers][rcpt_type] = mail.send(rcpt_type).join(",") if rcpt_type_val
    end

    sp_object[:content] = content
    sp_object.deep_merge!(mail.sparkpost_payload) if mail.sparkpost_payload
    sp_object
  end

  # Transform array of Mail::Attachment object to array of Hash with base64 encoded
  # attachment content
  #
  # @param [Array<Mail::Attachment>] attachments
  #
  # @return [Array<Hash>]
  def transform_attachments(attachments)
    attachments.map do |attachment|
      {
        name: attachment.filename,
        type: attachment.content_type,
        data: Base64.encode64(attachment.decoded)
      }
    end
  end

  # Fetch email address and name from Mail::Address object.
  #
  # @param [Mail::Address] address
  #
  # @return [Hash]
  def fetch_email_and_name(address)
    hash = {}
    hash[:email] = address.address if address.address
    hash[:name]  = address.name if address.name
    hash
  end

end
