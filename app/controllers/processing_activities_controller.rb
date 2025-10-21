class ProcessingActivitiesController < ApplicationController
  before_action :authenticate_user!

  def index
    render inertia: 'ProcessingActivities/Index', props: {
      activities: []
    }
  end
end
