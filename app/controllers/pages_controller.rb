class PagesController < ApplicationController
  allow_unauthenticated_access only: :home

  def home
    if authenticated?
      redirect_to app_root_path
    else
      render inertia: "Home"
    end
  end
end
