Reporter::Admin.controllers :scenario_groups do
  get :index do
    @title = "Scenario_groups"
    @scenario_groups = ScenarioGroup.all
    render 'scenario_groups/index'
  end

  get :new do
    @title = pat(:new_title, :model => 'scenario_group')
    @scenario_group = ScenarioGroup.new
    render 'scenario_groups/new'
  end

  post :create do
    @scenario_group = ScenarioGroup.new(params[:scenario_group])
    if @scenario_group.save
      @title = pat(:create_title, :model => "scenario_group #{@scenario_group.id}")
      flash[:success] = pat(:create_success, :model => 'ScenarioGroup')
      params[:save_and_continue] ? redirect(url(:scenario_groups, :index)) : redirect(url(:scenario_groups, :edit, :id => @scenario_group.id))
    else
      @title = pat(:create_title, :model => 'scenario_group')
      flash.now[:error] = pat(:create_error, :model => 'scenario_group')
      render 'scenario_groups/new'
    end
  end

  get :edit, :with => :id do
    @title = pat(:edit_title, :model => "scenario_group #{params[:id]}")
    @scenario_group = ScenarioGroup.find(params[:id])
    if @scenario_group
      render 'scenario_groups/edit'
    else
      flash[:warning] = pat(:create_error, :model => 'scenario_group', :id => "#{params[:id]}")
      halt 404
    end
  end

  put :update, :with => :id do
    @title = pat(:update_title, :model => "scenario_group #{params[:id]}")
    @scenario_group = ScenarioGroup.find(params[:id])
    if @scenario_group
      if @scenario_group.update_attributes(params[:scenario_group])
        flash[:success] = pat(:update_success, :model => 'Scenario_group', :id =>  "#{params[:id]}")
        params[:save_and_continue] ?
          redirect(url(:scenario_groups, :index)) :
          redirect(url(:scenario_groups, :edit, :id => @scenario_group.id))
      else
        flash.now[:error] = pat(:update_error, :model => 'scenario_group')
        render 'scenario_groups/edit'
      end
    else
      flash[:warning] = pat(:update_warning, :model => 'scenario_group', :id => "#{params[:id]}")
      halt 404
    end
  end

  delete :destroy, :with => :id do
    @title = "Scenario_groups"
    scenario_group = ScenarioGroup.find(params[:id])
    if scenario_group
      if scenario_group.destroy
        flash[:success] = pat(:delete_success, :model => 'Scenario_group', :id => "#{params[:id]}")
      else
        flash[:error] = pat(:delete_error, :model => 'scenario_group')
      end
      redirect url(:scenario_groups, :index)
    else
      flash[:warning] = pat(:delete_warning, :model => 'scenario_group', :id => "#{params[:id]}")
      halt 404
    end
  end

  delete :destroy_many do
    @title = "Scenario_groups"
    unless params[:scenario_group_ids]
      flash[:error] = pat(:destroy_many_error, :model => 'scenario_group')
      redirect(url(:scenario_groups, :index))
    end
    ids = params[:scenario_group_ids].split(',').map(&:strip)
    scenario_groups = ScenarioGroup.find(ids)
    
    if scenario_groups.each(&:destroy)
    
      flash[:success] = pat(:destroy_many_success, :model => 'Scenario_groups', :ids => "#{ids.to_sentence}")
    end
    redirect url(:scenario_groups, :index)
  end
end
