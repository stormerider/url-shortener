require File.expand_path('../test_helper', File.dirname(__FILE__))

class LinkTest < ActiveSupport::TestCase
  setup do
    @user = Factory(:user)
  end

  test "find_by_path" do
    link = Factory.create(:link, :shortcut => 'j', :url => 'http://jazz', :user => @user)
    link = Factory.create(:link, :shortcut => 'j/%s', :url => 'http://jazz/workitem/%s', :user => @user)
    assert_finds_url('http://jazz', 'j', @user)
    assert_finds_url('http://jazz/workitem/3', 'j/3', @user)
  end

  test "shortcuts must not contain spaces" do
    link = Factory.build(:link, :shortcut => 'j %s', :url => 'http://jazz/%s', :user => @user)
    assert_false link.valid?
    assert_equal 'Shortcut must not contain spaces', link.errors.full_messages.first
  end

  test "shortcuts must have at least one character and one slash before a wildcard" do
    link = Factory.build(:link, :shortcut => 'wi%s', :url => 'http://jazz/%s', :user => @user)
    assert_false link.valid?
    assert_match /must have at least one character and one slash/, link.errors.full_messages.first
  end

private
  def assert_finds_url(expected_url, path, user)
    assert_not_nil(link = Link.find_by_path(path))
      assert_equal(expected_url, link.generated_url)
    
    assert_difference('user.link_visits.count') do
      assert_equal(expected_url, Link.process_path_for_user!(path, user))
    end
  end
end