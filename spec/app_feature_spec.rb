require_relative 'app_spec.rb'

describe 'controller and viewer connection', :type => :feature do
  include Capybara::DSL
  
  it "does not affect when no viewer available", :js => true do
    visit "/controller"
    expect(page).to_not have_selector("#msg-area li")
    fill_in 'message', :with => [{:type => 'background', :value => '#ff0000'}].to_json
    click_button 'send'  
  end

  it "controller sends a message and then viewer get it", :js => true do
    using_session(:viewer) do
      visit "/"
      expect(page).to_not have_content("body")
    end
    using_session(:controller) do
      visit "/controller"
      expect(page).to_not have_selector("#msg-area li")
      fill_in 'message', :with => [{:type => 'background', :value => '#ff0000'}].to_json
      click_button 'send'
      expect(page).to_not have_selector("#msg-area li")
    end
    using_session(:viewer) do
      expect(page).to_not have_content("body")
      expect(page.evaluate_script('$(document.body).css("backgroundColor");')).to eq('rgb(255, 0, 0)')
    end

    # clear session
    using_session(:controller) do
      visit "about:blank"
    end
    using_session(:viewer) do
      visit "about:blank"
    end
  end

  it "viewers login and then controller get the notifications", :js => true do
    using_session(:controller) do
      visit "/controller"
      expect(page).to have_selector("#msg-area li", :count => 0)
    end
    using_session(:viewer1) do
      visit "/"
    end
    using_session(:controller) do
      expect(page).to have_selector("#msg-area li", :count => 1)
    end
    using_session(:viewer2) do
      visit "/"
    end
    using_session(:controller) do
      expect(page).to have_selector("#msg-area li", :count => 2)
    end

    # clear session
    using_session(:controller) do
      visit "about:blank"
    end
    using_session(:viewer1) do
      visit "about:blank"
    end
    using_session(:viewer2) do
      visit "about:blank"
    end
  end
end
