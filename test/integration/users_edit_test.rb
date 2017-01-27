require 'test_helper'

class UsersEditTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:josh)
    @other_user = users(:archer)
  end

  test "unsuccessful edit" do
    log_in_as(@user)
    get edit_user_path(@user)
    assert_template 'users/edit'
    patch user_path(@user), params: { user: {name: "",
                                             email: "foo@invalid",
                                             password: "foo",
                                             password_confirmation: "bar" } }

    assert_template 'users/edit'
  end

  test "successful edit" do
    # Log in as a valid user
    log_in_as(@user)
    # Navigate to the edit user page
    get edit_user_path(@user)
    # Are we actually on the edit page for users?
    assert_template 'users/edit'
    # Local variables to be used later
    name = "Foo Bar"
    email = "foo@bar.com"
    # Change the users name and email, then hit submit
    patch user_path(@user), params: { user: {name: name,
                                             email: email,
                                             password: "",
                                             password_confirmation: "" } }
    # Is there a flash at the top of the page
    assert_not flash.empty?
    # Are we on the user profile page now?
    assert_redirected_to @user
    # Did it actually update the users data
    @user.reload
    assert_equal name, @user.name
    assert_equal email, @user.email
  end

  test "successful edit with friendly forwarding" do
    # Navigate to the edit user page
    get edit_user_path(@user)
    # Log in as a valid user
    log_in_as(@user)
    # Are we actually on the edit page for users?
    assert_redirected_to edit_user_url(@user)
    # Local variables to be used later
    name = "Foo Bar"
    email = "foo@bar.com"
    # Change the users name and email, then hit submit
    patch user_path(@user), params: { user: {name: name,
                                             email: email,
                                             password: "",
                                             password_confirmation: "" } }
    # Is there a flash at the top of the page
    assert_not flash.empty?
    # Are we on the user profile page now?
    assert_redirected_to @user
    # Did it actually update the users data
    @user.reload
    assert_equal name, @user.name
    assert_equal email, @user.email
  end

  test "should redirect edit when not logged in" do
    get edit_user_path(@user)
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "should redirect update when not logged in" do
    patch user_path(@user), params: { user: { name: @user.name, email: @user.email } }
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "should redirect edit when logged in as wrong user" do
    log_in_as(@other_user)
    get edit_user_path(@user)
    assert flash.empty?
    assert_redirected_to root_url
  end

  test "should redirect update when logged in as wrong user" do
    log_in_as(@other_user)
    patch user_path(@user), params: { user: { name: @user.name, email: @user.email } }
    assert flash.empty?
    assert_redirected_to root_url
  end
end
