class CountsController < ApplicationController
  unloadable

	def user_issues
	if User.current!=nil
		@user = User.find(User.current)
		respond_to do |format|
		format.html { render :inline => "#{@user.my_page_counts}"}
		end
	end	
	end
end
