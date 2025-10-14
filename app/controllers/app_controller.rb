class AppController < ApplicationController
  def index
    render inertia: "App"
  end
end
