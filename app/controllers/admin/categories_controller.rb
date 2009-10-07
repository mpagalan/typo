class Admin::CategoriesController < Admin::BaseController
  cache_sweeper :blog_sweeper
  
  before_filter :find_resource, :only => [:edit, :update, :destroy]
  before_filter :page_heading,  :only => [:new, :edit]

  def index
    @categories = Category.find(:all, :order => :position, :conditions => { :parent_id => nil })
  end

  def new
    @category = Category.new
  end
  
  def edit
    render :action => "new"
  end
 
  def update
    @category.attributes = params[:category]
    save_category
  end

  def create
    @category = Category.new(params[:category])
    save_category
  end
 
  def destroy
    @category.destroy
    redirect_to admin_categories_url
  end

  def order
    Category.reorder(params[:category_list])
    render :nothing => true
  end

  def asort
    Category.reorder_alpha
    category_container
  end

  def category_container
    @categories = Category.find(:all, :order => :position)
    render :partial => "categories"
  end

  def reorder
    @categories = Category.find(:all, :order => :position)
    render :layout => false
  end
  
  private
  
  def save_category
    if @category.save
      flash[:notice] = _('Category was successfully created.')
      redirect_to admin_categories_url
    else
      flash[:error] = _('Category could not be saved.')
      render :action => "new"
    end
  end

  def find_resource
    @category = Category.find(params[:id])
  end
  
  def page_heading
    @page_heading = _("%s Category", action_name.capitalize)
  end
end
