class HomeController < ApplicationController
    def index
       @user = Employee.find_by(user_id: Current.user.id) if Current.user
    end
end
