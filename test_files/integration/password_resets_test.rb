require 'test_helper'

class PasswordResetsTest < ActionDispatch::IntegrationTest
  def setup
    ActionMailer::Base.deliveries.clear
    @user = users(:test_user)
  end

  test 'getting the password resets path displays the correct template' do
    get new_password_reset_path
    assert_template 'password_resets/new'
  end

  [{ test: 'empty', email: '', error_message: "can't be empty" },
   { test: 'incorrectly formatted', email: 'foo@bar', error_message: 'incorrectly formatted' },
   { test: 'not found', email: 'foo@bar.com', error_message: 'not found' }].each do |tests_hash|
    test "submitting the form results in an error when the form has an email that is #{tests_hash[:test]}" do
      post password_resets_path, params: { password_reset: { email: tests_hash[:email] } }
      assert_not flash.empty?
      assert_template 'password_resets/new'
      assert_select 'div.alert'
      assert_select 'div.alert-danger'
      assert_select 'button.close'
      assert_select 'div#flash_danger', "Email address #{tests_hash[:error_message]}"
    end
  end

  test 'valid email' do
    post password_resets_path, params: { password_reset: { email: @user.email } }
    assert_not_equal @user.reset_digest, @user.reload.reset_digest
    assert_equal 1, ActionMailer::Base.deliveries.size
    assert_not flash.empty?
    assert_redirected_to root_path

    user = assigns(:user)
    # Wrong email
    get edit_password_reset_path(user.reset_token, email: '')
    assert_redirected_to root_path
    # Inactive user
    user.toggle!(:activated)
    get edit_password_reset_path(user.reset_token, email: user.email)
    assert_redirected_to root_path
    user.toggle!(:activated)
    # Right email, wrong token
    get edit_password_reset_path('wrong token', email: user.email)
    assert_redirected_to root_path
    # Right email, right token
    get edit_password_reset_path(user.reset_token, email: user.email)
    assert_template 'password_resets/edit'
    assert_select 'input[name=email][type=hidden][value=?]', user.email
    # Invalid password & confirmation
    patch password_reset_path(user.reset_token), params: { email: user.email, user: { password: 'foobaz10', password_confirmation: 'bazfoo10' } }
    assert_select 'div.error-explanation'
    # Empty password
    patch password_reset_path(user.reset_token), params: { email: user.email, user: { password: '', password_confirmation: '' } }
    assert_select 'div.error-explanation'
    # Valid password & confirmation
    patch password_reset_path(user.reset_token), params: { email: user.email, user: { password: 'foobaz10', password_confirmation: 'foobaz10' } }
    assert logged_in?
    assert_not flash.empty?
    assert_redirected_to user
    assert_nil user.reload.reset_digest
    assert_nil user.reload.reset_sent_at
  end

  test 'expired token' do
    get new_password_reset_path
    post password_resets_path, params: { password_reset: { email: @user.email } }
    @user = assigns(:user)
    @user.update_attribute(:reset_sent_at, 3.hours.ago)
    patch password_reset_path(@user.reset_token), params: { email: @user.email, user: { password: 'barfoo10', password_confirmation: 'barfoo10' } }
    assert_response :redirect
    follow_redirect!
    assert response.body.include?('expired')
  end
end
