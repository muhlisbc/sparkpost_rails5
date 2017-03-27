require "rails"
require "sparkpost_rails/mailer"

module SparkpostRails
  class Railtie < ::Rails::Railtie
    config.before_configuration do
      ActionMailer::Base.add_delivery_method :sparkpost_rails, SparkpostRails::Mailer
    end
  end
end
