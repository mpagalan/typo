require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

require 'http_mock'

describe 'Admin::ArticlesController, in general', :shared => true do

  def mock_article(stubs={})
    @mock_article ||= mock_model(Article, stubs)
  end

  def should_load_the_needed_objects(method, action, params)
    load_needed_objects
    send method, action, params
    assigns[:drafts].should == [@draft_article]
    assigns[:resources].should == [@resource]
    assigns[:macros].should == @available_text_filter
  end
  
  private
  def load_needed_objects
    mock_article.stub!(:category_ids).and_return([])
    @draft_article = mock_model(Article)
    Article.stub!(:drafts).and_return([@draft_article])
    @available_text_filter = [Typo::Textfilter::Flickr, Typo::Textfilter::Lightbox]
    TextFilter.stub!(:available_filters).and_return(@available_text_filter)
    @resource = mock_model(Resource)
    Resource.stub!(:find).and_return([@resource])
  end
end


describe Admin::ArticlesController do
  it_should_behave_like 'Admin::ArticlesController, in general'

  before :each do
    @user = users(:tobi)
    request.session = {:user => @user.id}
  end
  
  describe 'GET index' do
    it "assigns all articles as @articles" do
      @mock_proxy = mock('proxy')
      @mock_proxy.stub!(:paginate).and_return([mock_article])
      Article.stub!(:search_without_drafts).and_return(@mock_proxy)
      get :index
      assigns[:articles].should == [mock_article]
    end

    it 'should render template index' do
      get 'index'
      response.should render_template('index')
    end

    it 'should see all published in index' do
      get :index, :search => {:published => '0', :published_at => '2008-08', :user_id => '2'}
      response.should render_template('index')
      response.should be_success
    end

    it 'should restrict only by searchstring' do
      get :index, :search => {:searchstring => 'originally'}
      assigns(:articles).should == [contents(:xmltest)]
      response.should render_template('index')
      response.should be_success
    end

    it 'should restrict by searchstring and published_at' do
      get :index, :search => {:searchstring => 'originally', :published_at => '2008-08'}
      assigns(:articles).should be_empty
      response.should render_template('index')
      response.should be_success
    end
  end

  describe 'GET new' do
    it "assigns a new article as @article" do
      Article.stub!(:new).and_return(mock_article)
      get :new
      assigns[:article].should == mock_article
    end
   
    it "assigns the needed objects to its proper variables" do
      should_load_the_needed_objects 'get', :new, {}
    end
  end

  describe 'GET edit' do
    before(:each) do
      mock_article(:access_by? => true)
      Article.stub!(:find).with("37").and_return(mock_article)
      load_needed_objects
    end

    it "assigns the requested article as @article" do
      get :edit, :id => "37"
      assigns[:article].should equal(mock_article)
    end

    #FIXME need to think of a better variable_name for selected categories
    it "assigns the selected category ids as @selected" do
      mock_category = mock_model(Category)
      mock_article.stub!(:category_ids).and_return([mock_category.id])
      get :edit, :id => "37"
      assigns[:selected].should == [mock_category.id]
    end

    it "assigns the needed objects to its proper variables" do
      should_load_the_needed_objects 'get', :edit, :id => "37"
    end
  end

  describe 'GET #insert_editor' do
    it 'should render _simple_editor' do
      get :insert_editor, :editor => 'simple'
      response.should render_template('admin/shared/_simple_editor')
    end

    it 'should render _visual_editor' do
      get :insert_editor, :editor => 'visual'
      response.should render_template('admin/shared/_visual_editor')
    end
  end

  describe "POST #create" do
    before(:each) do
      mock_article(:categories => true, :categorizations => [], :author => true)
    end

    def base_article(options={})
      { :title => "posted via tests!",
        :body => "A good body",
        :keywords => "tagged",
        :allow_comments => '1', 
        :allow_pings => '1' }.merge(options)
    end

    it "redirects to articles index" do
      mock_article.stub!(:save => true)
      Article.stub!(:new).and_return(mock_article)
      post :create, :article => {}
      response.should redirect_to(admin_articles_url)
    end

    it "assigns the selected category ids as @selected" do
      mock_article.stub!(:save => true)
      selected_categories = ["1", "25"]
      Article.stub!(:new).and_return(mock_article)
      post :create, :article => {}, :categories => selected_categories
      assigns[:selected].should == selected_categories
    end
    
    it "should assign current_user as author if author is blank" do
      mock_article.stub!(:author => nil, :save => true)
      Article.stub!(:new).and_return(mock_article)
      mock_article.should_receive(:author=).with(@user.login)
      mock_article.should_receive(:user=).with(@user)
      post :create, :article => {}
    end
    
    describe "with valid params" do
      it "assigns a newly created model as @model" do
        mock_article.stub!(:save => true)
        Article.stub!(:new).with({'these' => 'params'}).and_return(mock_article)
        post :create, :article => {:these => 'params'}
        assigns[:article].should equal(mock_article)
      end
      
      it "ables to create article as a draft" do
        mock_article.stub!(:save => true, :state => nil, :draft? => true)
        Article.stub!(:new).and_return(mock_article)
        mock_article.should_receive(:published=).with(false)
        mock_article.should_receive(:state=).with('draft')
        post :create, :article => {}, :draft => 'save as draft'
      end

      it 'should create article in future' do
        lambda do
          post :create, :article =>  base_article(:published_at => Time.now + 1.hour)
          response.should redirect_to admin_articles_url
          assigns(:article).should_not be_published
        end.should_not change(Article, :count_published_articles)
        assert_equal 1, Trigger.count
      end

    end

    describe "with auto_save params" do
      before(:each) do
        mock_article(:categories => true, :categorizations => [])
      end

      it "renders empty text when save is not successfull" do
        mock_article.stub!(:save => true, :permalink => true)
        Article.stub!(:new).with({'these' => 'params'}).and_return(mock_article)
        post :create, :article => {:these => 'params'}, :auto_save => true
        response.should_not have_text(nil)
      end

      it "renders proper rjs if save is successfull" do
        mock_article.stub!(:save => true, :permalink => true)
        Article.stub!(:new).with({'these' => 'params'}).and_return(mock_article)
        post :create, :article => {:these => 'params'}, :auto_save => true
        response.should have_rjs :replace_html, "permalink"
      end
    end
  end

  describe "PUT #update" do
    before(:each) do
      mock_article(:categories      => true,
                   :categorizations => [],
                   :author          => true,
                   :attributes=     => true,
                   :access_by?      => true)
      Article.should_receive(:find).with("37").and_return(mock_article)
    end

    it "should assign current_user as author if author is blank" do
      mock_article.stub!(:author => nil, :save => true)
      mock_article.should_receive(:author=).with(@user.login)
      mock_article.should_receive(:user=).with(@user)
      put :update, :id => "37"
    end

    describe "with valid params" do
      before(:each) do
        mock_article.stub!(:save => true)
      end

      it "should save the categories to article" do
        proxy_categories = mock("proxy_categories")
        mock_article.should_receive(:categorizations).and_return([])
        Category.stub!(:find).with([1]).and_return(proxy_categories)
        mock_article.should_receive(:categories=).with(proxy_categories)
        put :update, :id => "37", :categories => [1]
      end

      it "should save the attachments to article" do
        proxy_attachment = mock("proxy_attachment")
        proxy_resources  = mock("proxy_resources")
        proxy_file       = mock("proxy_file")
        Resource.should_receive(:create).and_return(proxy_attachment)
        proxy_attachment.stub!(:write_to_disk).and_return(proxy_attachment)
        proxy_file.stub!(:original_filename => true, :content_type => "text/sample")
        mock_article.stub!(:resources).and_return(proxy_resources)
        proxy_resources.should_receive(:<<).with(proxy_attachment)
        put :update, :id => "37", :attachments => {:attach => proxy_file}
      end
    end

    describe "with invalid params" do
      before(:each) do
        mock_article.stub!(:save => false)
      end
      
      it "should not save categories to article" do
        mock_article.should_not_receive(:categories=)
        put :update, :id => "37", :categories => [1]
      end

      it "should not save attachments to article" do
        mock_article.should_not_receive(:resources)
        put :update, :id => "37", :attachments => []
      end
    end
  end

  describe "#update_resource" do
    def mock_resource(stubs={})
      @mock_resource ||= mock_model(Resource, stubs)
    end

    before(:each) do
      mock_article.stub!(:resources => [])
      Article.stub!(:find).with("37").and_return(mock_article)
      @resources = [mock_model(Resource)]
      Resource.stub!(:find).with( :all, :order => 'filename').and_return(@resources)
      Resource.stub!(:find).and_return(mock_resource)
    end

    it "should assign article as @article" do
      put :update_resource, :id => "37"
      assigns[:article].should equal(mock_article)
    end

    it "should assign resource as @resource" do
      Resource.should_receive(:find).with("7").and_return(mock_resource)
      put :update_resource, :id => "37", :resource_id => "7"
    end

    it "should not accept :get request method" do
      mock_article.should_not_receive(:resources)
      get :update_resource, :id => "37"
    end

    it "should not accept :post request method" do
      mock_article.should_not_receive(:resources)
      post :update_resource, :id => "37"
    end
  end
end


describe Admin::ArticlesController, 'as publisher ' do
  it_should_behave_like 'Admin::ArticlesController, in general'
  
  before :each do
    @user = users(:user_publisher)
    request.session = {:user => @user.id}
    mock_article(:access_by? => true)
    mock_article.stub!(:category_ids).and_return([])
  end
 

  describe 'on edit action is accessed' do
    it 'should assigns the requested article as @article' do
      Article.should_receive(:find).with("37").and_return(mock_article)
      get :edit, :id => "37"
      assigns[:article].should equal(mock_article)
    end
  end
  
  describe 'when update action is accessed' do
    before(:each) do
      Article.should_receive(:find).with("37").and_return(mock_article)
    end
    
    describe "with article not his" do
      before(:each) do
        mock_article.stub!(:access_by? => false)
      end

      it 'should redirecto to index' do
        put :update, :id => "37"
        response.should redirect_to(:action => 'index')
      end

      it "should flash an error message" do
        put :update, :id => "37"
        flash[:error].should =~ /Error, you are not allowed to perform this action/
      end
    end
  end
  
  describe 'on in destory action is accessed' do
    it "destroys the requested model" do
      Article.should_receive(:find).with("37").and_return(mock_article)
      mock_article.should_receive(:destroy)
      delete :destroy, :id => "37"
    end
  
    it "redirects to the admin_articles list" do
      mock_article.stub!(:destroy).and_return(true)
      Article.stub!(:find).and_return(mock_article)
      delete :destroy, :id => "1"
      response.should redirect_to(admin_articles_url)
    end

    describe 'on article not his' do
      it "should redirecto to the admin_articles list with flash error" do
        mock_article.stub!(:access_by?).and_return(false)
        Article.stub!(:find).and_return(mock_article)
        delete :destroy, :id => "1"
        flash[:error].should_not be_empty
        response.should redirect_to(admin_articles_url)
      end
    end
  end

end
