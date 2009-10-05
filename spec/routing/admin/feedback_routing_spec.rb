require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Admin::FeedbackController do
  describe "route generation" do
    it "maps #index " do
      route_for(:controller => "admin/feedback", :action => "index").should == "/admin/feedback"
    end
 
    it "maps #new " do
      route_for(:controller => "admin/feedback", :action => "new").should == "/admin/feedback/new"
    end
    
    it "maps #create " do
      route_for(:controller => "admin/feedback", :action => "create").should =={:path => "/admin/feedback/", :method => :post}
    end
    
    it "maps #edit " do
      route_for(:controller => "admin/feedback", :action => "edit", :id => "1").should == "/admin/feedback/1/edit"
    end
    
    it "maps #update" do
      route_for(:controller => "admin/feedback", :action => "update", :id => "1").should == {:path => "/admin/feedback/1", :method => :put}
    end
    
    it "maps #destroy" do
      route_for(:controller => "admin/feedback", :action => "destroy", :id => "1").should == {:path => "/admin/feedback/1", :method => :delete}
    end

    it "maps #article" do
      route_for(:controller => "admin/feedback", :action => "article", :article_id => "1").should == "/admin/feedback/article/?article_id=1"
    end
  end


  describe "route recognition" do
    it "should reconize #article and its params" do
      params_from(:get, "/admin/feedback/article?article_id=1").should == {:controller => "admin/feedback", :action => "article", :article_id => "1"}
    end
  end
end
