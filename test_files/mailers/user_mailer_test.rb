require 'test_helper'

class UserMailerTest < ActionMailer::TestCase
  test 'account_activation_and_password_reset_emails' do
    user = users(:test_user)
    [{ type: 'activation', method: 'account_activation', subject: 'Account activation' },
     { type: 'reset', method: 'password_reset', subject: 'Password reset' }].each do |emails_hash|
      user.send("#{emails_hash[:type]}_token=", User.new_token)
      mail = UserMailer.send("#{emails_hash[:method]}", user)
      assert_equal "#{emails_hash[:subject]}", mail.subject
      assert_match user.send("#{emails_hash[:type]}_token"), mail.body.encoded
      assert_equal [user.email], mail.to
      assert_equal ['noreply@example.com'], mail.from
      assert_match user.email, mail.body.encoded
      assert_match CGI.escape(user.email), mail.body.encoded
    end
  end
end
