require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "/admin/categories/index.html.erb" do
  include Admin::BaseHelper

  before(:each) do
    #FIXME need to include the all the helpers
    template.stub!(:subtabs_for).and_return('')
    template.stub!(:render_void_table).and_return('')
    template.stub!(:alternate_class).and_return(alternate_class)
    assigns[:categories] = [stub_model(Category), stub_model(Category)]
  end

  it "renders the category container #div" do
    render
    response.should have_tag("div[id=category_container]") do
    end
  end

  it "renders a list of categories" do
    render
    response.should have_tag("table") do
      with_tag("tr", 4)
    end
  end
end


