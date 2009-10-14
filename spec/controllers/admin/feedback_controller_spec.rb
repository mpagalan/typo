require File.dirname(__FILE__) + '/../../spec_helper'

describe Admin::FeedbackController do

  integrate_views

  describe "destroy feedback with feedback from own article", :shared => true  do
    it 'should destroy feedback' do
      lambda do
        post 'delete', :id => feedback_from_own_article.id
      end.should change(Feedback, :count)
      lambda do
        Feedback.find(feedback_from_own_article.id)
      end.should raise_error(ActiveRecord::RecordNotFound)
    end

    it 'should redirect to feedback from article' do
      post 'delete', :id => feedback_from_own_article.id
      response.should redirect_to(:controller => 'admin/feedback', :action => 'article', :id => feedback_from_own_article.article.id)
    end

    it 'should not delete feedback in get request' do
      lambda do
        get 'delete', :id => feedback_from_own_article.id
      end.should_not change(Feedback, :count)
      lambda do
        Feedback.find(feedback_from_own_article.id)
      end.should_not raise_error(ActiveRecord::RecordNotFound)
      response.should redirect_to(:controller => 'admin/feedback', :action => 'article', :id => feedback_from_own_article.article.id)
    end
  end


  describe 'logged in admin user' do

    def feedback_from_own_article
      feedback(:spam_comment)
    end

    def feedback_from_not_own_article
      feedback(:spam_comment)
    end

    before do
      request.session = { :user => users(:tobi).id }
    end

    describe 'delete action' do

      it_should_behave_like "destroy feedback with feedback from own article"

      it "should delete feedback from article doesn't own" do
        lambda do
          post 'delete', :id => feedback_from_not_own_article.id
        end.should change(Feedback, :count)
        lambda do
          Feedback.find(feedback_from_not_own_article.id)
        end.should raise_error(ActiveRecord::RecordNotFound)
        response.should redirect_to(:controller => 'admin/feedback', :action => 'article', :id => feedback_from_not_own_article.article.id)
      end
    end

    describe 'index action' do

      def should_success_with_index(response)
        response.should be_success
        response.should render_template('index')
      end

      it 'should success' do
        get :index
        should_success_with_index(response)
        #FIXME : Test is useless because the pagination is on 10. Now there are 11
        #feedback, so there are several feedback :(
        assert_equal 10, assigns(:feedback).size #Feedback.count, assigns(:feedback).size
      end

      it 'should view only confirmed feedback' do
        get :index, :confirmed => 'f'
        should_success_with_index(response)
        Feedback.count(:conditions => { :status_confirmed => false }).should == assigns(:feedback).size
      end

      it 'should view only spam feedback' do
        get :index, :published => 'f'
        should_success_with_index(response)
        Feedback.count(:conditions => { :published => false }).should == assigns(:feedback).size
      end

      it 'should view unconfirmed_spam' do
        get :index, :published => 'f', :confirmed => 'f'
        should_success_with_index(response)
        Feedback.count(:conditions => { :published => false, :status_confirmed => false }).should == assigns(:feedback).size
      end

      it 'should get page 1 if page params empty' do
        get :index, :page => ''
        should_success_with_index(response)
      end

    end

    describe 'article action' do

      def should_success_with_article_view(response)
        response.should be_success
        response.should render_template('article')
      end

      it 'should see all feedback on one article' do
        get :article, :article_id => contents(:article1).id
        should_success_with_article_view(response)
        assigns(:article).should == contents(:article1)
        assigns(:comments).size.should == 2
      end

      it 'should see only spam feedback on one article' do
        get :article, :article_id => contents(:article1).id, :spam => 'y'
        should_success_with_article_view(response)
        assigns(:article).should == contents(:article1)
        assigns(:comments).size.should == 1
      end

      it 'should see only ham feedback on one article' do
        get :article, :article_id => contents(:article1).id, :ham => 'y'
        should_success_with_article_view(response)
        assigns(:article).should == contents(:article1)
        assigns(:comments).size.should == 1
      end

      it 'should redirect_to index if bad article id' do
        lambda{
          get :article, :article_id => 102302
        }.should raise_error(ActiveRecord::RecordNotFound)
      end

    end

    describe 'create action' do

      def base_comment(options = {})
        {"body"=>"a new comment", "author"=>"Me", "url"=>"http://typosphere.org", "email"=>"dev@typosphere.org"}.merge(options)
      end

      describe 'by get access' do
        it "should raise ActiveRecordNotFound if article doesn't exist" do
          lambda {
            get 'create', :article_id => 120431, :comment => base_comment
          }.should raise_error(ActiveRecord::RecordNotFound)
        end

        it 'should not create comment' do
          assert_no_difference 'Comment.count' do
            get 'create', :article_id => contents(:article1).id, :comment => base_comment
            response.should redirect_to(:action => 'article', :id => contents(:article1).id)
          end
        end

      end

      describe 'by post access' do
        it "should raise ActiveRecordNotFound if article doesn't exist" do
          lambda {
            post 'create', :article_id => 123104, :comment => base_comment
          }.should raise_error(ActiveRecord::RecordNotFound)
        end

        it 'should create comment' do
          assert_difference 'Comment.count' do
            post 'create', :article_id => contents(:article1).id, :comment => base_comment
            response.should redirect_to(:action => 'article', :id => contents(:article1).id)
          end
        end

        it 'should create comment mark as ham' do
          assert_difference 'Comment.count(:conditions => {:state => "ham"})' do
            post 'create', :article_id => contents(:article1).id, :comment => base_comment
            response.should redirect_to(:action => 'article', :id => contents(:article1).id)
          end
        end

      end

    end

    describe 'edit action' do

      it 'should render edit form' do
        get 'edit', :id => feedback(:comment2).id
        assigns(:comment).should == feedback(:comment2)
        assigns(:article).should == contents(:article1)
        response.should be_success
        response.should render_template('edit')
      end

    end

    describe 'update action' do

      it 'should update comment if post request' do
        post 'update', :id => feedback(:comment2).id, 
          :comment => {:author => 'Bob Foo2', 
                       :url => 'http://fakeurl.com',
                       :body => 'updated comment'}
        response.should redirect_to(:action => 'article', :id => contents(:article1).id)
        feedback(:comment2).reload
        feedback(:comment2).body.should == 'updated comment'
      end

      it 'should not  update comment if get request' do
        get 'update', :id => feedback(:comment2).id, 
          :comment => {:author => 'Bob Foo2', 
                       :url => 'http://fakeurl.com',
                       :body => 'updated comment'}
        response.should redirect_to(:action => 'edit', :id => feedback(:comment2).id)
        feedback(:comment2).reload
        feedback(:comment2).body.should_not == 'updated comment'
      end


    end
  end

  describe 'publisher access' do

    before :each do
      request.session = { :user => users(:user_publisher).id }
    end


    def feedback_from_own_article
      feedback(:comment_on_publisher_article)
    end
    
    def feedback_from_not_own_article
      feedback(:comment2)
    end

    describe 'delete action' do

      it_should_behave_like "destroy feedback with feedback from own article"

      it "should not delete feedback doesn't own" do
        lambda do
          post 'delete', :id => feedback_from_not_own_article.id
        end.should_not change(Feedback, :count)
        lambda do
          Feedback.find(feedbackfrom_not_own_article.id)
        end.should_not raise_error(ActiveRecord::RecordNotFound)
        response.should redirect_to(:controller => 'admin/feedback', :action => 'index')
      end
    end

    describe 'edit action' do

      it 'should not edit comment no own article' do
        get 'edit', :id => feedback_from_not_own_article.id
        response.should redirect_to(:action => 'index')
      end

      it 'should edit comment if own article' do
        get 'edit', :id => feedback_from_own_article.id
        response.should be_success
        response.should render_template('edit')
        assigns(:comment).should == feedback_from_own_article
        assigns(:article).should == feedback_from_own_article.article
      end

    end

    describe 'update action' do

      it 'should update comment if own article' do
        post 'update', :id => feedback_from_own_article.id, 
          :comment => {:author => 'Bob Foo2', 
                       :url => 'http://fakeurl.com',
                       :body => 'updated comment'}
        response.should redirect_to(:action => 'article', :id => feedback_from_own_article.article.id)
        feedback_from_own_article.reload
        feedback_from_own_article.body.should == 'updated comment'
      end

      it 'should not update comment if not own article' do
        post 'update', :id => feedback_from_not_own_article.id, 
          :comment => {:author => 'Bob Foo2', 
                       :url => 'http://fakeurl.com',
                       :body => 'updated comment'}
        response.should redirect_to(:action => 'index')
        feedback_from_not_own_article.reload
        feedback_from_not_own_article.body.should_not == 'updated comment'
      end

    end

    describe '#bulkops action' do

      before :each do
        post :bulkops, :bulkop_top => 'Delete all spam'
      end

      it 'should redirect to action' do
        @response.should redirect_to(:action => 'index')
      end
    end

  end

end

describe Admin::FeedbackController, "on more resource oriented" do
  def mock_feedback(stubs={})
    @mock_feedback ||= mock_model(Feedback, stubs)
  end
  
  before(:each) do
    @user = users(:tobi)
    request.session = {:user => @user.id}
  end

  describe "GET #index" do
    before(:each) do
      @proxy_scope = mock("proxy_scope")
      Feedback.should_receive(:most_recent).and_return(@proxy_scope)
    end
    
    def get_index(params={})
      get :index, params
    end
    
    #FIXME proper variable naming of feedback must me plural
    it "assigns feedbacks as @feedback" do
      @proxy_scope.stub!(:paginate).and_return([mock_feedback])
      get_index
      assigns[:feedback].should == [mock_feedback]
    end

    it "should chain on search named scope if search params is not blank?" do
      @proxy_scope.should_receive(:search).with("qwerty").and_return(@proxy_scope)
      @proxy_scope.stub!(:paginate).and_return([])
      get_index :search => "qwerty"
    end
    
    it "should not chain on search named scope if search params is blank?" do
      @proxy_scope.should_not_receive(:search).with(" ")
      @proxy_scope.stub!(:paginate).and_return([])
      get_index :search => " "
    end

    it "should chain on unpublished named scope if published is 'f'" do
      @proxy_scope.should_receive(:unpublished).and_return(@proxy_scope)
      @proxy_scope.stub!(:paginate).and_return([])
      get_index :published => "f"
    end
    
    it "should not chain on unpublished named scope if published is not 'f'" do
      @proxy_scope.should_not_receive(:unpublished)
      @proxy_scope.stub!(:paginate).and_return([mock_feedback])
      get_index :published => "z"
    end

    it "should chain on unconfirmed named scope if confirmed is 'f'" do
      @proxy_scope.should_receive(:unconfirmed).and_return(@proxy_scope)
      @proxy_scope.stub!(:paginate).and_return([])
      get_index :confirmed => "f"
    end

    it "should not chain on unconfirmed named scope if confirmed is not 'f'" do
      @proxy_scope.should_not_receive(:unconfirmed)
      @proxy_scope.stub!(:paginate).and_return([])
      get_index :confirmed => "x"
    end

    it "should chain on hams named scope if ham is 'f'" do
      @proxy_scope.should_receive(:hams).and_return(@proxy_scope)
      @proxy_scope.stub!(:paginate).and_return([])
      get_index :ham => 'f'
    end

    it "should not chain on hams named scope if ham is not 'f'" do
      @proxy_scope.should_not_receive(:hams)
      @proxy_scope.stub!(:paginate).and_return([])
      get_index :ham => 's'
    end
  end
end
