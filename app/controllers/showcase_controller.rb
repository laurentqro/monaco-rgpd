class ShowcaseController < ApplicationController
  allow_unauthenticated_access

  def index
    render inertia: "Showcase"
  end
end
