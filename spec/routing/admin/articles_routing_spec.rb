require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Admin::ArticlesController do
  describe "route generation" do
    it "maps #index " do
      route_for(:controller => "admin/articles", :action => "index").should == "/admin/articles"
    end
 
    it "maps #new " do
      route_for(:controller => "admin/articles", :action => "new").should == "/admin/articles/new"
    end
    
    it "maps #create " do
      route_for(:controller => "admin/articles", :action => "create").should =={:path => "/admin/articles/", :method => :post}
    end
    
    it "maps #edit " do
      route_for(:controller => "admin/articles", :action => "edit", :id => "1").should == "/admin/articles/1/edit"
    end
    
    it "maps #update" do
      route_for(:controller => "admin/articles", :action => "update", :id => "1").should == {:path => "/admin/articles/1", :method => :put}
    end
    
    it "maps #destroy" do
      route_for(:controller => "admin/articles", :action => "destroy", :id => "1").should == {:path => "/admin/articles/1", :method => :delete}
    end

    it "maps #insert_editor" do
      route_for(:controller => "admin/articles", :action => "insert_editor").should == {:path => "/admin/articles/insert_editor", :method => :get}
    end

    it "maps #attchment_box_add" do
      route_for(:controller => "admin/articles", :action => "attachment_box_add").should == {:path => "/admin/articles/attachment_box_add", :method => :get}
    end
  end


  describe "route recognition" do
    it "should reconize #auto_complete_for_article_keywords and its params" do
      params_from(:get, "/admin/articles/auto_complete_for_keywords").should == {:controller => "admin/articles", :action => "auto_complete_for_keywords"}
    end
    
    it "should reconize PUT #update_resource and its params" do
      params_from(:put, "/admin/articles/1/update_resource").should == {:controller => "admin/articles", :action => "update_resource", :id => "1"}
    end
    
    it "should reconize DELETE #update_resource and its params" do
      params_from(:delete, "/admin/articles/1/update_resource").should == {:controller => "admin/articles", :action => "update_resource", :id => "1"}
    end
  end
end
