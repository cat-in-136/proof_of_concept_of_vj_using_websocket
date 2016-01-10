require_relative 'app_spec.rb'

describe '/ connects ws://0.0.0.0/socket', :type => :feature do
  include Capybara::DSL

  it "send message and then get it", :js => true do
    visit "/"
    fill_in 'message', :with => 'test'
    expect(page).to_not have_content('test')
    click_button 'send'
    expect(page).to have_content('test')
  end

  it "get it when somebody else sends", :js => true do
    in_browser(:me) do
      visit "/"
      expect(page).to_not have_content('test')
    end
    in_browser(:somebody_else) do
      visit "/"
      fill_in 'message', :with => 'test'
      expect(page).to_not have_content('test')
      click_button 'send'
      expect(page).to have_content('test')
    end
    in_browser(:somebody_else) do
      expect(page).to have_content('test')
    end
  end

end
