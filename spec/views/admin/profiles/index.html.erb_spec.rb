require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "/admin/profiles/index.html.erb" do
  
  before(:each) do
   assigns[:user] = @user = stub_model(User, :new_record? => false)
  end
  
  describe "on the tempplate" do
    before(:each) do
      template.stub!(:render).with(:partial => 'admin/users/form').and_return(' ')
    end

    it "renders a user form" do
      render
      response.should have_tag("form[action=#{admin_profile_path(:id => @user.id)}][method=post]")
    end

    it "inside the form should have a hidden field for method" do
      render
      response.should have_tag("input[name=_method][value=put]")
    end
  end

end

