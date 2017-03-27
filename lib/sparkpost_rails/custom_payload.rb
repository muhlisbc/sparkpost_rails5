module Mail
  class Message

    attr_accessor :sparkpost_payload

  end
end

module ActionMailer
  class Base

    def sparkpost_payload(payload)
      message.sparkpost_payload = payload
    end

  end
end
