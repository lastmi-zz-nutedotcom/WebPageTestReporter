Reporter::Admin.controllers :scenarios do
  get :index do
    @title = "Scenarios"
    @scenarios = Scenario.all.order_by(:scenario_group.asc).order_by(:scenario_id.asc)
    render 'scenarios/index'
  end

  get :new do
    @title = pat(:new_title, :model => 'scenario')
    @scenario = Scenario.new
    render 'scenarios/new'
  end

  post :create do
    @scenario = Scenario.new(params[:scenario])
    if @scenario.save
      @title = pat(:create_title, :model => "scenario #{@scenario.id}")
      flash[:success] = pat(:create_success, :model => 'Scenario')
      params[:save_and_continue] ? redirect(url(:scenarios, :index)) : redirect(url(:scenarios, :edit, :id => @scenario.id))
    else
      @title = pat(:create_title, :model => 'scenario')
      flash.now[:error] = pat(:create_error, :model => 'scenario')
      render 'scenarios/new'
    end
  end

  get :edit, :with => :id do
    @title = pat(:edit_title, :model => "scenario #{params[:id]}")
    @scenario = Scenario.find(params[:id])
    if @scenario
      render 'scenarios/edit'
    else
      flash[:warning] = pat(:create_error, :model => 'scenario', :id => "#{params[:id]}")
      halt 404
    end
  end

  put :update, :with => :id do
    @title = pat(:update_title, :model => "scenario #{params[:id]}")
    @scenario = Scenario.find(params[:id])
    if @scenario
      if @scenario.update_attributes(params[:scenario])
        flash[:success] = pat(:update_success, :model => 'Scenario', :id =>  "#{params[:id]}")
        params[:save_and_continue] ?
          redirect(url(:scenarios, :index)) :
          redirect(url(:scenarios, :edit, :id => @scenario.id))
      else
        flash.now[:error] = pat(:update_error, :model => 'scenario')
        render 'scenarios/edit'
      end
    else
      flash[:warning] = pat(:update_warning, :model => 'scenario', :id => "#{params[:id]}")
      halt 404
    end
  end

  delete :destroy, :with => :id do
    @title = "Scenarios"
    scenario = Scenario.find(params[:id])
    if scenario
      if scenario.destroy
        flash[:success] = pat(:delete_success, :model => 'Scenario', :id => "#{params[:id]}")
      else
        flash[:error] = pat(:delete_error, :model => 'scenario')
      end
      redirect url(:scenarios, :index)
    else
      flash[:warning] = pat(:delete_warning, :model => 'scenario', :id => "#{params[:id]}")
      halt 404
    end
  end

  delete :destroy_many do
    @title = "Scenarios"
    unless params[:scenario_ids]
      flash[:error] = pat(:destroy_many_error, :model => 'scenario')
      redirect(url(:scenarios, :index))
    end
    ids = params[:scenario_ids].split(',').map(&:strip)
    scenarios = Scenario.find(ids)
    
    if scenarios.each(&:destroy)
    
      flash[:success] = pat(:destroy_many_success, :model => 'Scenarios', :ids => "#{ids.to_sentence}")
    end
    redirect url(:scenarios, :index)
  end
end
