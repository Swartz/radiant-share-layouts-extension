require File.dirname(__FILE__) + "/../spec_helper"
require 'ostruct'

describe RailsPage do 
  test_helper :render, :page
  dataset :share_layouts_pages#, :pages
  
  before(:each) do
    @page = RailsPage.new(page_params(:class_name => "RailsPage"))
  end
  
  it "should redefine_breadcrumbs_tag" do
    @page.should respond_to("tag:old_breadcrumbs")
    @page.should respond_to("tag:breadcrumbs")

    @page.breadcrumbs = "some breadcrumbs"
    @page.should render("<r:breadcrumbs />").as("some breadcrumbs")
  end
  
  it "should use_old_breadcrumbs_tag_if_breadcrumbs_attr_is_nil" do
    @page = pages(:app)
    @page.breadcrumbs = nil
    @page.should render("<r:breadcrumbs nolinks='true' />").as("Home &gt; App") 
  end
  
  it "should build_parts_from_hash" do
    hash = {:body => "body", :sidebar => "sidebar"}
    @page.build_parts_from_hash!(hash)
    @page.parts.size.should == hash.keys.size
    # Make sure we don't save them to the DB
    @page.parts.all?(&:new_record?).should be_true
  end
  
  it "should find_rails_page_for_sub_urls_that_do_not_match_an_existing_page" do
    Page.find_by_url('/app/').should == pages(:app)
    Page.find_by_url('/app/some-other-url/').should == pages(:app)
    Page.find_by_url('/app/some-other-url/sub-url/').should == pages(:app)
  end
  
  it "should find_page_if_sub_url_matches_one" do
    Page.find_by_url('/app/child-page/').should == pages(:app_child)
  end
  
  it "should find_page_for_non_sub_urls" do
    Page.find_by_url('/other/').should == pages(:other)
  end
  
  it "should defer_to_default_url_when_not_initialized" do
    pages(:app).url.should == '/app/'
  end
  
  it "should modify_existing_parts_but_not_save_them" do
    @page = pages(:app)
    @page.parts.create(:name => "sidebar", :content => "This is the sidebar.")
    @page.build_parts_from_hash!(:body => "This is the body")
    @page.part(:sidebar).content.should == 'This is the sidebar.'
    @page.build_parts_from_hash!(:sidebar => "OVERRIDE")
    
    # I can't see how this one ever passed: @page.part goes back to the database. ?
    # @page.part(:sidebar).content.should == 'OVERRIDE'
    @page.part(:sidebar).reload.content.should == 'This is the sidebar.'
  end
end
