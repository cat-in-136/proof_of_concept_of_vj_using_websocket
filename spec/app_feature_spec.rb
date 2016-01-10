require_relative 'app_spec.rb'

describe 'controller and viewer connection', :type => :feature do
  include Capybara::DSL

  it "controller sends a message and then viewer get it", :js => true do
    using_session(:viewer) do
      visit "/"
      expect(page).to_not have_selector("#msg-area li")
    end
    using_session(:controller) do
      visit "/controller"
      fill_in 'message', :with => 'controller2viewer'
      click_button 'send'
      expect(page).to_not have_selector("#msg-area li")
    end
    using_session(:viewer) do
      expect(page).to have_selector("#msg-area li")
    end
  end

  it "viewers send messages and then controller get them", :js => true do
    using_session(:controller) do
      visit "/controller"
      expect(page).to_not have_selector("#msg-area li")
    end
    using_session(:viewer1) do
      visit "/"
      fill_in 'message', :with => 'viewer1'
      click_button 'send'
      expect(page).to_not have_selector("#msg-area li")
    end
    using_session(:controller) do
      expect(page).to have_selector("#msg-area li", :text => "viewer1")
    end
    using_session(:viewer2) do
      visit "/"
      fill_in 'message', :with => 'viewer2'
      click_button 'send'
      expect(page).to_not have_selector("#msg-area li")
    end
    using_session(:controller) do
      expect(page).to have_selector("#msg-area li", :text => "viewer2")
    end
  end
end
