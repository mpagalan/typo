require File.dirname(__FILE__) + '/../../spec_helper'

describe Admin::ProfilesController do

  def mock_user(stubs={})
    @mock_user ||= mock_model(User, stubs)
  end
  
  before(:each) do
    current_user = mock_model(User)
    request.session = { :user => current_user }
    controller.stub!(:login_required).and_return(true)
    controller.stub!(:current_user).and_return(current_user)
  end
  
  describe "GET index" do
    before(:each) do
      get :index
    end

    it "should respond to success" do
      response.should be_success
    end

    it "should render the #index template" do
      response.should render_template(:index)
    end

    it "should assign current_user to @user" do
      assigns[:user].should == controller.send(:current_user)
    end
  end


  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested model" do
        User.should_receive(:find).with("37").and_return(mock_user)
        mock_user.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :user => {:these => 'params'}
      end

      it "assigns the requested user as @user" do
        User.stub!(:find).and_return(mock_user(:update_attributes => true))
        put :update, :id => "1"
        assigns[:user].should equal(mock_user)
      end

      it "redirects to the admin" do
        User.stub!(:find).and_return(mock_user(:update_attributes => true))
        put :update, :id => "1"
        response.should redirect_to(admin_url)
      end

    end
    
    describe "with invalid params" do
      it "updates the requested user" do
        User.should_receive(:find).with("37").and_return(mock_user)
        mock_user.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :user => {:these => 'params'}
      end

      it "assigns the model as @user" do
        User.stub!(:find).and_return(mock_user(:update_attributes => false))
        put :update, :id => "1"
        assigns[:user].should equal(mock_user)
      end

      it "re-renders the 'index' template" do
        User.stub!(:find).and_return(mock_user(:update_attributes => false))
        put :update, :id => "1"
        response.should render_template('index')
      end
    end

  end
end
