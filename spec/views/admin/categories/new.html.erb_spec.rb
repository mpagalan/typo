require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "/admin/categories/new.html.erb" do
  include Admin::BaseHelper

  before(:each) do
    #FIXME need to include the all the helpers
    template.stub!(:subtabs_for).and_return('')
    template.stub!(:cancel_or_save).and_return('save and cancel')
  end

  describe "when category is a new record" do
    before(:each) do
      assigns[:category] = stub_model(Category, :new_record? => true)
      assigns[:page_heading] = _("%s Category", "New")
    end

    it "renders new categories form" do
      render
      response.should have_tag("form[action=?][method=post]", admin_categories_path) do
      end
    end
  end

  describe "when category is not a new record" do
    before(:each) do
      assigns[:category] = @category = stub_model(Category, :new_record? => false)
      assigns[:page_heading] = _("%s Category", "Edit")
    end
    
    it "renders new categories form" do
      render
      response.should have_tag("form[action=#{admin_category_path(:id => @category.id)}][method=post]") do
        with_tag("input[value=put]")
      end
    end
  end
end


