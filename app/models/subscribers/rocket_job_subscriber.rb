module Subscribers
  class RocketJobSubscriber < ::Acapi::Subscription
    include Acapi::Notifiers

    def self.subscription_details
      [/acapi\.info\.events\..*/]
    end

    def call(event_name, e_start, e_end, msg_id, payload)
      Rails.logger.error("RocketJobSubscriber") { "*******************************" }
      Rails.logger.error("RocketJobSubscriber") { payload.inspect }
    end
  end
end
