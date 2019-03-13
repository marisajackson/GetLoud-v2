class UsersController < ApplicationController

    def set_metro_area
      @user = User.find(current_user['id'])
      @user.metro_area = params[:metroArea]
      @user.save!

      EventImportJob.perform_later @user.metro_area

      render :json => current_user['metro_area']
    end
end
