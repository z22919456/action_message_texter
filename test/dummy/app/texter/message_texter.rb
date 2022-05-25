class MessageTexter < ActionMessageTexter::Base
  add_delivery_method :base, SMSProvider::Base
  def test
    sms(to: 'fdsjk', content: 'fskjfl')
  end
end
