require_relative 'app_spec.rb'

describe 'controller and viewer connection', :type => :feature do
  include Capybara::DSL
  
  it "does not affect when no viewer available", :js => true do
    visit "/controller"
    expect(page).to_not have_selector("#msg-area li")
    fill_in 'message', :with => [{:type => 'background', :value => '#ff0000'}].to_json
    click_button 'send'  
  end
  
  it "disallow multiple controller sessions", :js => true do
    using_session(:controller1) do
      visit "/controller"
      expect(page).to_not have_selector("#msg-area li")
    end
    using_session(:controller2) do
      visit "/controller"
      expect(page).to_not have_selector("#msg-area li")
    end
    using_session(:controller1) do
      expect(page).to have_selector("#msg-area li", :count => 1)
    end

    # clear session
    using_session(:controller1) do
      visit "about:blank"
    end
    using_session(:controller2) do
      visit "about:blank"
    end
  end

  it "controller rejects invalid message", :js => true do
    visit "/controller"
    expect(page).to_not have_selector("#msg-area li")
    fill_in 'message', :with => '[invalid JSON'
    click_button 'send'
    expect(page).to have_selector("#msg-area li", :count => 1, :text => /error/i)
    fill_in 'message', :with => ''
    click_button 'send'
    expect(page).to have_selector("#msg-area li", :count => 2, :text => /error/i)
    fill_in 'message', :with => JSON.generate({:type => 'background', :value => '#000000'})
    click_button 'send'
    expect(page).to have_selector("#msg-area li", :count => 3, :text => /error/i)
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

  it "controller sends a message to specific viewer", :js => true do
    viewer_guid = [nil, nil]

    using_session(:controller) do
      visit "/controller"
      expect(page).to have_selector("#msg-area li", :count => 0)
    end
    using_session(:viewer1) do
      visit "/"
    end
    using_session(:viewer2) do
      visit "/"
    end
    using_session(:controller) do
      li = page.all("#msg-area li", :text => /connected/i)
      expect(li.size).to eq(2)
      viewer_guid[0] = $1 if li[0].text =~ /([0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{12})/i
      viewer_guid[1] = $1 if li[1].text =~ /([0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{12})/i
      expect(viewer_guid[0]).not_to be_empty
      expect(viewer_guid[1]).not_to be_empty
    end

    using_session(:controller) do
      visit "/controller"
      expect(page).to_not have_selector("#msg-area li")
      fill_in 'message', :with => [{:type => 'background', :target => viewer_guid[0], :value => '#ff0000'}].to_json
      click_button 'send'
      fill_in 'message', :with => [{:type => 'background', :target => viewer_guid[1], :value => '#00ff00'}].to_json
      click_button 'send'

      # wrong target which shall be ignored
      fill_in 'message', :with => [{:type => 'background', :target => 'wrong target', :value => '#0000ff'}].to_json
      click_button 'send'
    end
    using_session(:viewer1) do
      expect(page).to_not have_content("body")
      expect(page.evaluate_script('$(document.body).css("backgroundColor");')).to eq('rgb(255, 0, 0)')
    end
    using_session(:viewer2) do
      expect(page).to_not have_content("body")
      expect(page.evaluate_script('$(document.body).css("backgroundColor");')).to eq('rgb(0, 255, 0)')
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

  it "controller set group name", :js => true do
    viewer_guid = [nil, nil]

    using_session(:controller) do
      visit "/controller"
      expect(page).to have_selector("#msg-area li", :count => 0)
    end
    using_session(:viewer1) do
      visit "/"
    end
    using_session(:viewer2) do
      visit "/"
    end
    using_session(:controller) do
      li = page.all("#msg-area li", :text => /connected/i)
      expect(li.size).to eq(2)
      viewer_guid[0] = $1 if li[0].text =~ /([0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{12})/i
      viewer_guid[1] = $1 if li[1].text =~ /([0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{12})/i
      expect(viewer_guid[0]).not_to be_empty
      expect(viewer_guid[1]).not_to be_empty
    end

    using_session(:controller) do
      fill_in 'message', :with => [
        {:type => 'set_group', :target => viewer_guid[0], :value => %w[gr-any gr-viewer1] },
        {:type => 'set_group', :target => viewer_guid[1], :value => %w[gr-any gr-viewer2] },
        {:type => 'background', :target => "gr-any", :value => '#ff0000'},
      ].to_json
      click_button 'send'
    end
    using_session(:viewer1) do
      expect(page).to_not have_content("body")
      expect(page.evaluate_script('$(document.body).css("backgroundColor");')).to eq('rgb(255, 0, 0)')
    end
    using_session(:viewer2) do
      expect(page).to_not have_content("body")
      expect(page.evaluate_script('$(document.body).css("backgroundColor");')).to eq('rgb(255, 0, 0)')
    end

    using_session(:controller) do
      fill_in 'message', :with => [{:type => 'background', :target => "gr-viewer1", :value => '#00ff00'}].to_json
      click_button 'send'
    end
    using_session(:viewer1) do
      expect(page).to_not have_content("body")
      expect(page.evaluate_script('$(document.body).css("backgroundColor");')).to eq('rgb(0, 255, 0)')
    end
    using_session(:viewer2) do
      expect(page).to_not have_content("body")
      expect(page.evaluate_script('$(document.body).css("backgroundColor");')).to eq('rgb(255, 0, 0)')
    end

    using_session(:controller) do
      fill_in 'message', :with => [{:type => 'background', :target => "gr-viewer2", :value => '#0000ff'}].to_json
      click_button 'send'
    end
    using_session(:viewer1) do
      expect(page).to_not have_content("body")
      expect(page.evaluate_script('$(document.body).css("backgroundColor");')).to eq('rgb(0, 255, 0)')
    end
    using_session(:viewer2) do
      expect(page).to_not have_content("body")
      expect(page.evaluate_script('$(document.body).css("backgroundColor");')).to eq('rgb(0, 0, 255)')
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
