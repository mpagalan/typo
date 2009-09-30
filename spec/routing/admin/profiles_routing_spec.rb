require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Admin::ProfilesController do
  describe "route generation" do
    it "maps #index " do
      route_for(:controller => "admin/profiles", :action => "index").should == "/admin/profiles"
    end
 
    it "maps #update" do
      route_for(:controller => "admin/profiles", :action => "update", :id => "1").should == {:path => "/admin/profiles/1", :method => :put}
    end

  end
end
