require File.dirname(__FILE__) + '/../../spec_helper'

describe 'Admin::CategoriesController in general', :shared => true do
  before do
    request.session = {:user => users(:tobi).id}
  end

  def mock_category(stubs={})
    @mock_category ||= mock_model(Category, stubs)
  end
end

describe Admin::CategoriesController do
  it_should_behave_like 'Admin::CategoriesController in general'
  integrate_views

  def test_order
    assert_equal categories(:software), Category.find(:first, :order => :position)
    get :order, :category_list => [categories(:personal).id, categories(:hardware).id, categories(:software).id]
    assert_response :success
    assert_equal categories(:personal), Category.find(:first, :order => :position)
  end

  def test_asort
    assert_equal categories(:software), Category.find(:first, :order => :position)
    get :asort
    assert_response :success
    assert_template "_categories"
    assert_equal categories(:hardware), Category.find(:first, :order => :position)
  end

  def test_category_container
    get :category_container
    assert_response :success
    assert_template "_categories"
    assert_tag :tag => "table",
      :children => { :count => Category.count + 2,
        :only => { :tag => "tr",
          :children => { :count => 2,
            :only => { :tag => /t[dh]/ } } } }
  end

  def test_reorder
    get :reorder
    assert_response :success
    assert_template "reorder"
    assert_select 'ul#category_list > li', Category.count
    assert_select 'a', '(Done)'
  end
end

describe Admin::CategoriesController, "an more rspec oriented" do
  it_should_behave_like 'Admin::CategoriesController in general'
  
  describe "GET index" do
    it "assigns all categories to @categories" do
      Category.stub!(:find).and_return([mock_category])
      get :index
      assigns[:categories].should == [mock_category]
    end

    it "renders the index template" do
      get :index
      response.should render_template("index")
    end
  end

  describe "GET new" do
    it "assigns a new category as @category" do
      Category.stub!(:new).and_return(mock_category)
      get :new
      assigns[:category].should equal(mock_category)
    end

    it "assigns page_headin as @page_heading" do
      get :new
      assigns[:page_heading].should =~ /New Category/
    end

    it "should render the new template" do
      get :new
      response.should render_template('new')
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "assigns a newly created category as @category" do
        Category.stub!(:new).with({'these' => 'params'}).and_return(mock_category(:save => true))
        post :create, :category => {:these => 'params'}
        assigns[:category].should equal(mock_category)
      end

      it "redirects to the admin/categories list" do
        Category.stub!(:new).and_return(mock_category(:save => true))
        post :create, :category => {}
        response.should redirect_to(admin_categories_url)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved category as @category" do
        Category.stub!(:new).with({'these' => 'params'}).and_return(mock_category(:save => false))
        post :create, :category => {:these => 'params'}
        assigns[:category].should equal(mock_category)
      end

      it "re-renders the 'new' template" do
        Category.stub!(:new).and_return(mock_category(:save => false))
        post :create, :category => {}
        response.should render_template('new')
      end

      it "flash an error message 'Category could not be saved.'" do
        Category.stub!(:new).and_return(mock_category(:save => false))
        post :create, :category => {}
        flash[:error].should =~ /Category could not be saved\./
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested category" do
      Category.should_receive(:find).with("37").and_return(mock_category)
      mock_category.should_receive(:destroy)
      delete :destroy, :id => "37"
    end
  
    it "redirects to the admin_categories list" do
      Category.stub!(:find).and_return(mock_category(:destroy => true))
      delete :destroy, :id => "1"
      response.should redirect_to(admin_categories_url)
    end
  end

  describe "GET edit" do
    it "assigns the requested category as @category" do
      Category.stub!(:find).with("37").and_return(mock_category)
      get :edit, :id => "37"
      assigns[:category].should equal(mock_category)
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested model" do
        Category.should_receive(:find).with("37").and_return(mock_category(:save => true))
        mock_category.should_receive(:attributes=).with({'these' => 'params'})
        put :update, :id => "37", :category => {:these => 'params'}
      end

      it "assigns the requested model as @category" do
        Category.stub!(:find).and_return(mock_category(:attributes= => true, :save => true))
        put :update, :id => "1"
        assigns[:category].should equal(mock_category)
      end

      it "redirects to the model" do
        Category.stub!(:find).and_return(mock_category(:attributes= => true, :save => true))
        put :update, :id => "1"
        response.should redirect_to(admin_categories_url)
      end

    end
    
    describe "with invalid params" do
      it "updates the requested model" do
        Category.should_receive(:find).with("37").and_return(mock_category(:save => false))
        mock_category.should_receive(:attributes=).with({'these' => 'params'})
        put :update, :id => "37", :category => {:these => 'params'}
      end

      it "assigns the model as @category" do
        Category.stub!(:find).and_return(mock_category(:attributes= => true, :save => false))
        put :update, :id => "1"
        assigns[:category].should equal(mock_category)
      end

      it "re-renders the 'edit' template" do
        Category.stub!(:find).and_return(mock_category(:attributes= => true, :save => false))
        put :update, :id => "1"
        response.should render_template('new')
      end

      it "flash an error message 'Category could not be saved.'" do
        Category.stub!(:find).and_return(mock_category(:attributes= => true, :save => false))
        put :update, :id => 1
        flash[:error].should =~ /Category could not be saved\./
      end
    end
  end

end
