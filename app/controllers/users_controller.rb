class UsersController < ApplicationController

    def set_metro_area
      @user = User.find(current_user['id'])
      @user.metro_area = params[:metroArea]
      @user.save!

      event = Event.where('metro_area', params[:metroArea]).first

      if(!event)
        EventImportJob.perform_later @user.metro_area
      end

      render :json => current_user['metro_area']
    end
end
