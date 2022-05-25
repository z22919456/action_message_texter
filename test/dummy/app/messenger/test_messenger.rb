class TestMessenger < ActionTextMessenger::Base
  add_delivery_method :base, SMSProvider::Base
  def test
    sms(to: 'fdsjk', content: 'fskjfl')
  end
end
