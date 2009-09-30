class Admin::ProfilesController < Admin::BaseController
  helper Admin::UsersHelper
  
  def index
    @user = current_user
    get_profiles
  end

  def update
    @user = User.find(params[:id])
    get_profiles

    respond_to do |format|
      if @user.update_attributes(params[:user])
        flash[:notice] = 'User was successfully updated.'
        format.html { redirect_to admin_url }
        format.xml  { head :ok }
      else
        format.html { render :action => "index" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  protected
  def get_profiles
    @profiles = Profile.find(:all, :order => 'id')
  end
end
