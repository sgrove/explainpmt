class UsersController < ApplicationController
  before_filter :require_admin_privileges, :except => [:new, :create, :index, :project,
    :authenticate, :login, :logout, :register ]
  skip_before_filter :check_authentication, :only => [ :authenticate, :login, :new, :create, :register ]
  popups :new, :edit

  def index
    if @project
      @page_title = "Project Team"
      @users = @project.users
      render :action => 'project'
    else
      @page_title = "System Users"
      @users = User.find( :all, :order => 'last_name ASC, first_name ASC')
    end
  end

  def new
    @user = User.new
    respond_to do |format|
      format.html{@page_title = "New User"}
      format.js{
      render :update do |page|
      page[:SystemStatus].hide
      page[:form].visual_effect :fade, :duration => 0.5
      page.delay 1 do
        page[:form].replace_html :partial => 'users/register_form', :locals => {:user => @user}
        page[:form].visual_effect :appear
      end
      end
      }
    end
  end

  def edit
    @user = User.find params[:id]
    @page_title = @user.full_name
  end

  def create
    @user = User.new params[:user]
    if @user.valid?
      @user.save
      flash[:status] = "User account for #{@user.full_name} has been created."
      if @project
        @project.users << @user
        flash[:status] = "User account for #{@user.full_name} has been " +
                          "created and added to the project team."
      end
      render :template => 'layouts/refresh_parent_close_popup'
    else
      if @project
        render :action => "new", :layout => "popup", :locals => {:project_id => @project.id}
      else
        render :action => "new", :layout => "popup"
      end
    end
  end

  def register
    @user = User.new params[:user]
      render :update do |page|
         page[:SystemStatus].hide
         if @user.save
          page[:form].visual_effect :fade, :duration => 0.5
          page.delay 1 do
            page[:form].replace_html :partial => 'users/login_form'
            page[:form].visual_effect :appear
          end
          page.delay 1 do
            page[:SystemStatus].replace_html "User account for #{user.full_name} has been created."
            page[:SystemStatus].visual_effect :appear
          end
        else
          page[:SystemStatus].replace_html error_messages_for(:user)
          page[:SystemStatus].visual_effect :appear
      end
    end    
  end

  def update
    @user = User.find params[:id]
    original_password = @user.password
    @user.attributes = params[:user]
    if params[:user][:password] == ''
      @user.password = @user.password_confirmation = original_password
    end
    if @user == current_user and !@user.admin? and
      current_user.admin?
      @user.admin = 1
      flash[:error] = "You can not remove admin privileges from yourself."
    end
    if @user.valid?
      @user.save
      flash[:status] = "User account for #{@user.full_name} has been updated."
      render :template => 'layouts/refresh_parent_close_popup'
    else
      render :action => "edit", :layout => "popup"
    end
  end

  def delete
    user = User.find params[:id]
    if user == current_user
      flash[:error] = "You can not delete your own account." if user == current_user
    else
      user.destroy
      flash[:status] = "User account for #{user.full_name} has been deleted."
    end
    redirect_to :controller => 'users', :action => 'index'
  end
  
  def login
    render :layout => false
  end
  
  def authenticate
    session[ :current_user ] = User.authenticate( params[ :username ],
      params[ :password ] )
    respond_to do |wants|
      wants.html do
        if session[ :current_user ]
          if session[ :return_to ]
            redirect_to_path session[ :return_to ]
            session[ :return_to ] = nil
          else
            redirect_to :controller => 'dashboard', :action => 'index'
          end
        else
          flash[ :error ] = 'You entered an invalid username and/or password.'
          redirect_to :controller => 'users', :action => 'login'
        end
      end
      wants.xml do
        if session[ :current_user ]
          render :xml => session[ :current_user ].to_xml( :dasherize => false )
        else
          @error = 'You entered an invalid username and/or password.'
          render :template => 'shared/error', :layout => false
        end
      end
    end
  end
  
  def logout
    session[ :current_user ] = nil
    flash[:status] = "You have been logged out."
    redirect_to :controller => 'users', :action => 'login'
  end

  protected

  def require_admin_privileges
    case action_name
    when 'edit','update'
      super if params[:id].to_i != current_user.id
    else
      super
    end
  end
end
